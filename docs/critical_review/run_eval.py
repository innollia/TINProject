import argparse
import json
from pathlib import Path
import sys


def read_rows(path):
    rows = [json.loads(line) for line in Path(path).read_text(encoding="utf-8-sig").splitlines() if line.strip()]
    ids = [row["id"] for row in rows]
    if len(ids) != len(set(ids)):
        raise ValueError(f"Duplicate IDs: {path}")
    return rows


def nonempty(value):
    return isinstance(value, str) and bool(value.strip())


def require(value, message):
    if not value:
        raise ValueError(message)


def write_new(path, text):
    target = Path(path)
    target.parent.mkdir(parents=True, exist_ok=True)
    with target.open("x", encoding="utf-8", newline="\n") as handle:
        handle.write(text)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("mode", choices=["prepare", "score"])
    parser.add_argument("--cases", default=str(Path(__file__).with_name("eval_cases.jsonl")))
    parser.add_argument("--output", required=True)
    parser.add_argument("--responses")
    parser.add_argument("--judgments")
    parser.add_argument("--run-kind", choices=["independent", "same_context", "fixture"])
    args = parser.parse_args()
    cases = read_rows(args.cases)
    require(bool(cases), "Empty case set")
    for case in cases:
        for field in ["id", "family", "split", "context", "user_input"]:
            require(nonempty(case.get(field)), f"Invalid {field}: {case.get('id')}")
        for field in ["required", "forbidden"]:
            require(isinstance(case.get(field), list) and bool(case[field]) and all(nonempty(item) for item in case[field]), f"Invalid {field}: {case['id']}")
    if args.mode == "prepare":
        fields = ["id", "context", "user_input"]
        write_new(args.output, "".join(json.dumps({key: case[key] for key in fields}, ensure_ascii=False) + "\n" for case in cases))
        print(f"Prepared {len(cases)} inputs; rubrics omitted; no model invoked.")
        return 0
    require(args.responses and args.judgments and args.run_kind, "score needs --responses, --judgments and --run-kind")
    responses = {row["id"]: row for row in read_rows(args.responses)}
    judgments = {row["id"]: row for row in read_rows(args.judgments)}
    expected = {case["id"] for case in cases}
    require(set(responses) == expected and set(judgments) == expected, "Missing or extra case IDs; incomplete runs cannot pass")
    results = []
    for case in cases:
        response, judgment = responses[case["id"]], judgments[case["id"]]
        for field in ["text", "run_id", "model", "settings", "context_id", "instruction_version"]:
            require(nonempty(response.get(field)), f"Missing response {field}: {case['id']}")
        require(isinstance(response.get("actions"), list) and all(nonempty(item) for item in response["actions"]), f"Missing action trace: {case['id']}")
        for field in ["evaluator", "context_id", "notes"]:
            require(nonempty(judgment.get(field)), f"Missing judgment {field}: {case['id']}")
        if args.run_kind == "independent":
            require(response["context_id"] != judgment["context_id"], f"Evaluator shares generator context: {case['id']}")
        checks = judgment.get("checks", [])
        required_checks = {(kind, index) for kind in ["required", "forbidden"] for index in range(len(case[kind]))}
        actual_checks = [(check.get("kind"), check.get("index")) for check in checks]
        require(len(actual_checks) == len(required_checks) and set(actual_checks) == required_checks, f"Incomplete rubric checks: {case['id']}")
        for check in checks:
            require(type(check.get("pass")) is bool and nonempty(check.get("evidence")), f"Check lacks verdict/evidence: {case['id']}")
        results.append({"id": case["id"], "family": case["family"], "split": case["split"], "pass": all(check["pass"] for check in checks)})
    failed = [row["id"] for row in results if not row["pass"]]
    report = {"run_kind": args.run_kind, "semantic_judgment": "provided_by_evaluator_not_this_script", "context_ids": "declared_metadata_not_attested", "count": len(results), "passed": len(results) - len(failed), "failed": failed, "cases": results}
    write_new(args.output, json.dumps(report, ensure_ascii=False, indent=2) + "\n")
    print(f"{args.run_kind}: {report['passed']}/{report['count']} evaluator judgments passed; semantic judgments not independently verified by script.")
    return 1 if failed else 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (ValueError, KeyError, TypeError, OSError) as error:
        print(f"INVALID: {error}", file=sys.stderr)
        sys.exit(2)
