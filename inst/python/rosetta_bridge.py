import json
from linkml.validator import validate

def validate_json_instance(schema_path, instance_json, target_class=None):
    """
    Validates a JSON string (object or list of objects) against a LinkML schema.
    Returns a dictionary with 'ok' (bool) and 'issues' (list).
    """
    try:
        # 1. Parse the JSON instance
        instance_data = json.loads(instance_json)
        
        all_issues = []
        
        # 2. Helper function to run validation on a single item
        def run_check(item, index_label=""):
            report = validate(item, schema_path, target_class)
            if report.results:
                # Format errors to include row context
                return [f"{index_label}{str(r)}" for r in report.results]
            return []

        # 3. Handle Lists (DataFrames) vs Single Objects
        if isinstance(instance_data, list):
            for i, row in enumerate(instance_data):
                # Validate each row individually
                row_errors = run_check(row, index_label=f"[Row {i+1}] ")
                all_issues.extend(row_errors)
        else:
            # Handle single object
            all_issues.extend(run_check(instance_data))

        # 4. Return Summary
        if all_issues:
            return {"ok": False, "issues": all_issues}
        else:
            return {"ok": True, "issues": []}
            
    except Exception as e:
        # Catch system errors (like file not found or bad JSON)
        return {"ok": False, "issues": [str(e)]}