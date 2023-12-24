FROM python:3.8.17

WORKDIR /app
COPY requirements.txt .
RUN pip3 install -r requirements.txt
ADD app.py /app
ENV HOME=/app
ENV PATH "/app:$PATH"
ENTRYPOINT ["python", "app.py"]
