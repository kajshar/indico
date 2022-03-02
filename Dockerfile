FROM python:3.9

RUN apt-get update && apt-get install -y build-essential

ENV APP_HOME /indico
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD requirements.txt $APP_HOME
RUN pip install -r requirements.txt

ADD . $APP_HOME
