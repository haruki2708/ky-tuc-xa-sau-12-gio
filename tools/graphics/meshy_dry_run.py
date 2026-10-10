"""Offline planning and simulated ledger only. No API transport or secret access."""
import argparse
import hashlib
import json
import os
from pathlib import Path


def positive_int(value, label):
    if type(value) is not int or value <= 0:
        raise ValueError(label + " must be a positive integer")
    return value


def plan(request):
    # Only allow known fields: prompts, tokens and provider payloads never enter logs.
    if not isinstance(request, dict) or set(request) != {"asset_id", "license", "steps", "ceiling_credits", "max_attempts"}:
        raise ValueError("Unexpected or missing request fields")
    if not isinstance(request["asset_id"], str) or not request["asset_id"].replace("-", "").replace("_", "").isalnum():
        raise ValueError("Invalid asset ID")
    if request["license"] not in ("CC0-1.0", "CC-BY-4.0", "CC-BY-3.0"):
        raise ValueError("License requires integrator decision")
    ceiling = positive_int(request["ceiling_credits"], "ceiling")
    attempts = positive_int(request["max_attempts"], "max_attempts")
    if not isinstance(request["steps"], list) or not request["steps"]:
        raise ValueError("At least one estimated step is required")
    total = 0
    names = set()
    for step in request["steps"]:
        if not isinstance(step, dict) or set(step) != {"name", "estimated_credits"}:
            raise ValueError("Invalid step fields")
        if not isinstance(step["name"], str) or step["name"] in names:
            raise ValueError("Invalid or duplicate step")
        if step["name"] not in ("preview", "refine", "texture", "remesh", "rig", "animate"):
            raise ValueError("Unknown planning step (not a provider endpoint)")
        names.add(step["name"])
        total += positive_int(step["estimated_credits"], "estimated_credits")
    worst_case = total * attempts
    if worst_case > ceiling:
        raise ValueError("Worst-case estimate exceeds total ceiling")
    fingerprint = hashlib.sha256(json.dumps(request, sort_keys=True, separators=(",", ":")).encode()).hexdigest()
    return {"mode": "offline_dry_run", "fingerprint": fingerprint, "asset_id": request["asset_id"],
            "estimate_per_attempt": total, "reserved_credits": worst_case,
            "steps": request["steps"],
            "ceiling_credits": ceiling, "max_attempts": attempts, "network_calls": 0,
            "paid_execution": "unavailable_pending_G1_G2", "price_verified": False}


def new_ledger(proposal, balance):
    positive_int(balance, "simulated balance")
    if balance < proposal["reserved_credits"]:
        raise ValueError("Insufficient simulated balance")
    return {"mode": "fixture_only", "fingerprint": proposal["fingerprint"], "state": "planned",
            "task_id": None, "attempts": 0, "balance_before": balance,
            "reserved_credits": proposal["reserved_credits"], "consumed_credits": None,
            "resume_count": 0, "events": []}


def transition(ledger, proposal, event, task_id=None, consumed=None, balance_after=None):
    # Persist this returned state before any future real submit. There is no submit here.
    if ledger["fingerprint"] != proposal["fingerprint"]:
        raise ValueError("Request changed; cannot reuse ledger")
    result = json.loads(json.dumps(ledger))
    state = result["state"]
    if event == "reserve_submit":
        if state != "planned" or result["attempts"] >= proposal["max_attempts"]:
            raise ValueError("Duplicate or ambiguous submission blocked")
        result.update(state="submission_unknown", attempts=result["attempts"] + 1)
    elif event == "accepted":
        if state != "submission_unknown" or not isinstance(task_id, str) or not task_id.startswith("fixture-"):
            raise ValueError("Only simulated task IDs are accepted")
        result.update(state="pending", task_id=task_id)
    elif event == "timeout":
        if state not in ("submission_unknown", "pending"):
            raise ValueError("Timeout requires a submitted task")
        # Unknown submit remains blocked; known task is polled, never submitted again.
    elif event == "resume":
        if state != "pending" or not result["task_id"]:
            raise ValueError("Reconcile unknown submission manually; do not POST again")
        if result["resume_count"] >= 3:
            raise ValueError("Fixture poll limit reached; operator review required")
        result["resume_count"] += 1
    elif event in ("succeeded", "failed"):
        if state != "pending":
            raise ValueError("Completion requires known pending task")
        if type(consumed) is not int or consumed < 0 or type(balance_after) is not int or balance_after < 0:
            raise ValueError("Completion needs credit reconciliation")
        result.update(state=event, consumed_credits=consumed, balance_after=balance_after)
        result["balance_delta"] = result["balance_before"] - balance_after
        result["reconciled"] = result["balance_delta"] == consumed
        result["over_budget"] = consumed > result["reserved_credits"]
        if not result["reconciled"] or result["over_budget"]:
            result["state"] = "reconciliation_required"
    else:
        raise ValueError("Unknown fixture event")
    result["events"].append(event)
    return result


def save_event(path, proposal, event, balance=100, **kwargs):
    root = Path(__file__).resolve().parents[2] / "build" / "graphics" / "fixture-ledgers"
    root = root.resolve()
    path = path.resolve()
    if not path.is_relative_to(root) or path.suffix != ".json":
        raise ValueError("Fixture ledger must be under build/graphics/fixture-ledgers/*.json")
    path.parent.mkdir(parents=True, exist_ok=True)
    lock = path.with_suffix(".lock")
    # Exclusive lock prevents two local operators from advancing the same ledger.
    descriptor = os.open(lock, os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o600)
    temporary = path.with_suffix(".tmp")
    try:
        os.close(descriptor)
        if event == "init":
            if path.exists():
                raise ValueError("Ledger already exists; resume it")
            result = new_ledger(proposal, balance)
        else:
            result = transition(json.loads(path.read_text()), proposal, event, **kwargs)
        with temporary.open("w", encoding="utf-8") as stream:
            json.dump(result, stream, indent=2)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, path)
        return result
    finally:
        lock.unlink()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("request", type=Path)
    parser.add_argument("--fixture-ledger", type=Path)
    parser.add_argument("--event", choices=("init", "reserve_submit", "accepted", "timeout", "resume", "succeeded", "failed"))
    parser.add_argument("--fixture-task-id")
    parser.add_argument("--balance", type=int, default=100)
    parser.add_argument("--consumed", type=int)
    parser.add_argument("--balance-after", type=int)
    args = parser.parse_args()
    # No live switch, no network imports, no environment/key reads.
    request = json.loads(args.request.read_text(encoding="utf-8-sig"))
    proposal = plan(request)
    if bool(args.fixture_ledger) != bool(args.event):
        raise ValueError("Fixture event and ledger must be specified together")
    output = proposal
    if args.fixture_ledger:
        output = save_event(args.fixture_ledger, proposal, args.event, balance=args.balance,
                            task_id=args.fixture_task_id, consumed=args.consumed, balance_after=args.balance_after)
    print(json.dumps(output, indent=2))


if __name__ == "__main__":
    try:
        main()
    except (ValueError, KeyError, TypeError, OSError):
        print('{"status":"FAIL","reason":"Invalid offline request; inspect locally"}')
        raise SystemExit(1)
