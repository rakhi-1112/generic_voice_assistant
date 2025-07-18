class UserDataHelper:
    def __init__(self, db):
        """
        Initialize with Firestore client.
        :param db: Firestore client instance (firebase_admin.firestore.client)
        """
        self.db = db

    def get_user_id(self, username):
        """
        Returns the user_id for the given username.
        :param username: str
        :return: str or None
        """
        query = self.db.collection("users").where("username", "==", username).limit(1).stream()
        for doc in query:
            return doc.id   # In my design, each document represents a user, and the document_id represents the user_id
        return None

    def check_username(self, username):
        """
        Checks if a username exists in the database.
        :param username: str
        :return: bool
        """
        query = self.db.collection("users").where("username", "==", username).limit(1).stream()
        return any(True for _ in query)
