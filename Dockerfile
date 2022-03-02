FROM python:3.5.3

RUN apt-get update && apt-get install -y build-essential

ENV APP_HOME /indico
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD requirements.txt $APP_HOME
RUN pip install -r requirements.in

ADD . $APP_HOME
