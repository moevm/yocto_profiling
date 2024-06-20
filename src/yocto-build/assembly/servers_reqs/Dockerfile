FROM alpine:3.18

ARG PORT
ENV PORT=${PORT}

RUN apk add --no-cache python3 py3-pip nano

WORKDIR /app
COPY get_ip.py /app/

EXPOSE ${PORT}

ENTRYPOINT ["sh", "-c"]
CMD ["python3 -m http.server -b $(python3 get_ip.py) $PORT; sleep infinity"]