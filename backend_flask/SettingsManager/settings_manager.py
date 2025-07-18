import json
from typing import Any

# TODO: This class needs proper exception handling
class SettingsManager:
    def __init__(self, config_path: str = "config.json"):
        self.config_path = config_path
        self._load_config()

    def _load_config(self):
        with open(self.config_path, "r") as file:
            self.settings = json.load(file)

    def get(self, category: str, key: str) -> Any:
        return self.settings.get(category, {}).get(key).get('value')

    def set(self, category: str, key: str, value: Any):
        if category not in self.settings:
            self.settings[category] = {}
        self.settings[category][key]['value'] = value
        self.__save()

    def __save(self):
        with open(self.config_path, "w") as file:
            json.dump(self.settings, file, indent=2)

    def get_category(self, category: str) -> dict:
        return self.settings.get(category, {})

    def __str__(self):
        return json.dumps(self.settings, indent=2)