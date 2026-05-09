FROM python:3.12-slim

ENV FLASK_RUN_PORT=5000

WORKDIR /app

COPY setup.py .
COPY hello/ hello/

RUN pip install --no-cache-dir .

EXPOSE $FLASK_RUN_PORT

CMD ["flask", "--app", "hello", "run", "--host", "0.0.0.0"]
