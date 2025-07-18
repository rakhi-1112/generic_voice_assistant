from .tts_routes import tts_blueprint
from .stt_routes import stt_blueprint
from .voicechat_routes import voicechat_blueprint
from .investment_adv_routes import investment_adv_blueprint
from .user_routes import user_blueprint
from .textchat_routes import textchat_blueprint

def register_blueprints(app):
    app.register_blueprint(tts_blueprint, url_prefix="/api/tts")
    app.register_blueprint(stt_blueprint, url_prefix="/api/stt")
    app.register_blueprint(voicechat_blueprint, url_prefix="/api/voicechat")
    app.register_blueprint(textchat_blueprint, url_prefix="/api/textchat")

    app.register_blueprint(investment_adv_blueprint, url_prefix="/api/investment_adv")
    app.register_blueprint(user_blueprint, url_prefix="/api/user")