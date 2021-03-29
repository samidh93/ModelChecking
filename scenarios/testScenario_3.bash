#!/bin/bash

# meant to be used with adore_ci docker container
# in the context of a gitlab ci job

# setup script to fail if any one of the following command fails
set -Eeuxo pipefail

echo "just testing 3"


# setup and run simulation
export ROS_DISTRO=noetic
export ROS_MASTER_URI=http://localhost:11353
export SUMO_HOME=/home/adore_workspace_dir/src/adore/sumo


#source /opt/ros/noetic/setup.bash
source /home/adore_workspace_dir/install/setup.bash


cd /home/adore_workspace_dir/src/adore/test/ci
roscore -p 11353 &
sleep 1
timeout 120 roslaunch -p 11353 --wait test003_lane_change_00.launch  > /home/outputdir/build/test_ci_3.log
#mv /home/outputdir/build/test_ci_3*bag /home/outputdir/build/test_ci.bag
chmod +x ModelChecker.py
python3 ModelChecker.py --input /home/outputdir/build/test_ci_3.bag --output /home/outputdir/build/test_ci_3.txt --topic /vehicle3/ENV/propositions /vehicle3/VEH/ax /vehicle3/odom /vehicle3/traffic
EVAL=$(head -n 1 /home/outputdir/build/test_ci_3.txt)
if [ "$EVAL" = "test passed" ]; then echo "test3" >> /home/outputdir/build/variables && echo $EVAL; else EVAL=false && echo $EVAL && exit 1; fi


