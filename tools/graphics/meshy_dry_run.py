"""Historical G0 command compatibility; no Meshy or Tripo network transport."""
from asset_dry_run import legacy_plan as plan, new_ledger, transition, save_event, main


if __name__ == "__main__":
    try:
        main(legacy=True)
    except (ValueError, KeyError, TypeError, OSError):
        print('{"status":"FAIL","reason":"Invalid historical offline request"}')
        raise SystemExit(1)
