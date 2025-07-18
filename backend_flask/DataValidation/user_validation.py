import re

class UserValidation:
    @staticmethod
    def validate(data, user_data_helper):
        required_fields = ['username', 'password_hash', 'email']
        for field in required_fields:
            if field not in data:
                return False, f"Missing field: {field}"

        if not isinstance(data['username'], str) or len(data['username']) > 32:
            return False, "Username must be a string up to 32 characters long"
        
        if user_data_helper.check_username(data['username']):
            return False, "Username already exists"

        if not isinstance(data['password_hash'], str) or len(data['password_hash']) < 10:
            return False, "Password hash must be a string of sufficient length"

        if not isinstance(data['email'], str) or not re.match(r"[^@]+@[^@]+\.[^@]+", data['email']):
            return False, "Invalid email format"

        return True, ""
