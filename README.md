SFLive-Paris2016-Workflow
=========================

Installation
------------

    composer install
    bin/console doctrine:database:create
    bin/console doctrine:schema:update --force

If you update the workflow configuration, you will need to regenerate the
SVG by running the following command:

    # For the task
    bin/console  workflow:build:svg state_machine.task
    # For the article
    bin/console  workflow:build:svg workflow.article

Dockerized version
-------------------------------------------------------------------------

Just clone the project and:

    $ cd SFLive-Paris2016-Workflow
    $ make install

`m̀ake install` performs the following steps:

- check `.env` existence & copy `.env.dist` if `.env` not exists
- build & start the containers
- execute `composer install`
- create database

More info:

    $ make
    # or 
    $ make help 