import yaml
import os

class Config:
  def __init__(self, config_file, whitelist=None):
    with open(config_file, 'r') as cnf:
      for prop,val in yaml.load(cnf, yaml.SafeLoader).items():
        if whitelist != None and prop not in whitelist:
          continue
        setattr(self, prop, val)

class Logbox:
  def __init__(self, logdir, loglist):
    if not os.path.exists(logdir):
      os.mkdir(logdir)
    self.logger = dict()
    for logname in loglist:
      logger = logging.getLogger(logname)
      fh = logging.FileHandler(f"{logdir}/{logger}.log")
      logger.addHandler(fh)
      self.logger[logname] = logger
