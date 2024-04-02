## General

This is a fork of the InvConplus tool by FranklinLiu.
Paper about the tool can be found here: https://arxiv.org/abs/2401.00650

## Requirements

There is a requirements file for dependancies that are required to run the tool. Please add any module in requirements.txt that you needed to install to get the tool runing.

## Chifra

Trueblooks command line tool chifra is needed to run the tool on the machine being used.
A guide to install chifra can be found here:
https://www.trueblocks.io/docs/install/install-core/

To use it a valid RPC endpoint is needed. This nodes needs to have tracing availeble. The endpoint needs to added in chifra config file.
which can be found using. If a remote nodes is used for this the number transaction that can be fethed will probably be quite limited
and --maxCount mention under Running should be limited
chifra config --paths

## Quicknode/Node

Currently the tool is using Quicknode API to observe contracts state changes. QuickNode requires a API key with build plan to support the
API calls used. Anyone associted with ASSERT can borrow a key please
contact gustavak@kth.se my copy.

## Running

Runcommand:
python -m invconplus.main

Args:
--maxCount
Gives the number of transaction used to generate invariants.
--minSupport
Gives the minimal number of transaction used
--address
Contract address for invariant mining
--output_dir
Location to store mined invariants.
Can be defined in const.py aswell.
--configuration
Slice criteria as json file. Format of this file unknown at the time of writing. Use default.

## Config

In const.py various constants are used for configuration of the tool.

## Results

Results can be found as a JSON file in the Trace2Inv/result folder.

## HELP

Please contact gustavak@kth.se if you have any problems running this
