class InvestmentAdvisoryValidation:

    REQUIRED_FIELDS = [
        'username',
        'age_group',
        'inv_frequency',
        'inv_goal',
        'inv_risk',
        'inv_amount'
    ]

    @staticmethod
    def validate(data):
        for field in InvestmentAdvisoryValidation.REQUIRED_FIELDS:
            if field not in data:
                return False, f"Missing field: {field}"

        if data['inv_frequency'] not in ['recurring', 'lumpsum']:
            return False, "inv_frequency must be 'recurring' or 'lumpsum'"

        try:
            age = int(data['age_group'])
            if not (0 <= age <= 150):
                return False, "age_group must be between 0 and 150"
        except (ValueError, TypeError):
            return False, "age_group must be a number"

        try:
            risk = int(data['inv_risk'])
            if not (0 <= risk <= 100):
                return False, "inv_risk must be between 0 and 100"
        except (ValueError, TypeError):
            return False, "inv_risk must be a number"

        return True, ""
