.. include:: /macros.rst

.. _cossdev-guide-reintegrate-uobjcoll:

Re-integrate |uobjcoll| into |coss|
===================================

..  note::  This section is still a work-in-progress

- use uberspark_loaduobjcoll interface
- if uberspark root-of-trust is found then it will bind sentinels; else it will just select the call
- include uberspark, include uobjcoll/xxx
- invoke hello_world as you would have normally; only this time it is executing as a |uobj|
