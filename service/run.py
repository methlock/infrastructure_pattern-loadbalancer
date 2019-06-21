import os
import socket
import random
import datetime
import threading
from time import sleep

import peewee
from flask import Flask, jsonify
from peewee import MySQLDatabase


app = Flask(__name__)
db = MySQLDatabase('db',
                   user='user', passwd='password',
                   host=os.environ['DB_HOST'], port=3306)


class TasksTable(peewee.Model):
    """Python representation of 'Tasks' table from MySQL."""

    # field id will be created automatically - primary key
    status = peewee.TextField()
    created = peewee.DateTimeField(default=datetime.datetime.now)
    finished = peewee.DateTimeField(default=datetime.datetime.now)
    duration = peewee.IntegerField(default=0)

    class Meta:
        database = db


class Task:
    def __init__(self):
        self.task = TasksTable(status='initialized')
        self.task.save()

        thread = threading.Thread(target=self.work, args=())
        thread.daemon = True
        thread.start()

    @property
    def id(self):
        return int(self.task.id)

    @property
    def status(self):
        return str(self.task.status)

    @status.setter
    def status(self, new_status):
        self.task.status = new_status
        self.task.save()

    def work(self):
        self.task.created = datetime.datetime.now()
        self.status = 'in progress'
        sleep(random.randint(5, 60))  # simulates random computation
        self.task.finished = datetime.datetime.now()
        self.task.duration = (self.task.finished - self.task.created).total_seconds()
        self.status = 'done'


@app.route("/")
def index():
    return f"Hello from service behind Load Balancer. This is container with id {socket.gethostname()}"


@app.route("/newTask")
def task():
    new_task = Task()
    return f'New task with number {new_task.id} created'


@app.route("/tasks")
def task_status():
    response = {
        task.id: {
            'created': task.created,
            'finished': task.finished,
            'status': task.status,
            'duration': task.duration
        } for task in TasksTable}
    return jsonify(response)


if __name__ == "__main__":
    TasksTable.create_table()
    app.run(debug=True, host='0.0.0.0', port=5000)
