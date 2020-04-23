import logging
import yaml

from vrpg_common import Config, Logbox
from routes import render

try:
  from flask import Flask
except ImportError ie:

cnf = Config("config.yaml")
lbx = Logbox(cnf.logdir, cnf.logs)

flapp = Flask("Virtual RPG Webserver")

flapp.route("/display/<mapname>", render.table)

if __name__ == '__main__':
  flapp.debug = True
  flapp.run(host=cnf.host, port=int(cnf.port))
