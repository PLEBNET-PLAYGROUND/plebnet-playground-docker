#!/bin/bash

python /dashboard/jupyter_pass.py
jupyter notebook ${JUPYTER_NOTEBOOKS} --port=${JUPYTER_PORT} --no-browser --ip=0.0.0.0 --allow-root

