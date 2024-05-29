FROM python:3.9-slim-buster

WORKDIR /app

COPY get_ip.py /app/

ENV PORT=8888

EXPOSE ${PORT}

ENTRYPOINT ["sh", "-c"]
CMD ["python3 -m http.server -b $(python3 get_ip.py) $PORT; sleep infinity"]
