def friendly_personalized_greeting(input_file_contents: bytes) -> str:
    *greeting, name = input_file_contents.decode().split()
    personalized_response = "Hello. Nice to meet you, {}".format(name.strip('"'))
    return personalized_response


def convert_bytes_to_utf8_text(utf8_file_contents: bytes) -> str:
    return utf8_file_contents.decode()


def convert_utf8_text_to_bytes(input_text: str) -> bytes:
    return input_text.encode()
