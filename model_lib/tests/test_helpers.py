from model_lib.src.helpers import friendly_personalized_greeting


def test_friendly_personalized_greeting_runs() -> None:
    friendly_personalized_greeting(b"Something")
