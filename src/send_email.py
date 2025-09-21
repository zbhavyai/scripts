#!/usr/bin/env python3

import logging
import smtplib
import ssl
from contextlib import suppress
from email.mime.text import MIMEText


def test_smtp_config() -> dict[str, str]:
    return {
        "HOST": "smtp.example.com",
        "PORT": "587",
        "USERNAME": "sender@example.com",
        "PASSWORD": "xxxxxxxxxxxxxxxxxx",
        "SENDER_EMAIL": "sender@example.com",
    }


def test_recipients() -> list[str]:
    return ["receiver1@example.com", "receiver2@example.com"]


def test_email_content() -> str:
    return """
    <html>
      <body>
        <h1 style="color:blue;">Test Email</h1>
        <p>This is a test email sent from the send_email.py script.</p>
      </body>
    </html>
    """


def configure_logging() -> None:
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)7s] (%(lineno)4d) %(funcName)s: %(message)s",
        handlers=[
            logging.StreamHandler(),
        ],
    )


def send_email(smtp_cfg: dict[str, str], to_list: list[str], subject: str, body: str) -> None:
    if not smtp_cfg:
        logging.warning("SMTP configuration not found; skipping email notification.")
        return

    if not to_list:
        logging.warning("Email recipients not configured; skipping email notification.")
        return

    msg = MIMEText(body, "html", "utf-8")
    msg["Subject"] = subject
    msg["From"] = smtp_cfg["SENDER_EMAIL"]
    msg["To"] = ", ".join(to_list)

    port = int(smtp_cfg["PORT"])
    mode = "ssl" if port == 465 else ("starttls_required" if port == 587 else "starttls_optional")
    server = None

    try:
        # connect SSL or plain
        server = (
            smtplib.SMTP_SSL(smtp_cfg["HOST"], port, timeout=10)
            if mode == "ssl"
            else smtplib.SMTP(smtp_cfg["HOST"], port, timeout=10)
        )
        server.ehlo()

        # starttls handling
        if mode != "ssl":
            if server.has_extn("starttls"):
                try:
                    server.starttls(context=ssl.create_default_context())
                    server.ehlo()
                except Exception as e:
                    if mode == "starttls_required":
                        logging.error("STARTTLS required on 587 but failed: %s", e)
                        return
                    logging.warning(
                        "STARTTLS optional failed on port %s; continuing unencrypted: %s", port, e
                    )
            elif mode == "starttls_required":
                logging.error("Port 587 but server does not advertise STARTTLS; aborting send.")
                return

        # Login and Send
        server.login(smtp_cfg["USERNAME"], smtp_cfg["PASSWORD"])
        server.sendmail(smtp_cfg["SENDER_EMAIL"], to_list, msg.as_string())
        logging.info("Email sent to %s via %s:%s (%s)", to_list, smtp_cfg["HOST"], port, mode)

    except Exception as e:
        logging.exception("Email send failed: %s", e)
    finally:
        if server:
            with suppress(Exception):
                server.quit()


def main() -> None:
    configure_logging()
    send_email(test_smtp_config(), test_recipients(), "Test Subject", test_email_content())


if __name__ == "__main__":
    main()
