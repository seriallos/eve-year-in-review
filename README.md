EVE Year in Review
==================

Showcase of new character stats for EVE Fanfest 2015

Dev Prerequisites
-----------------

* node + npm (built with 0.10.35)

Get Started
-----------

    npm install
    alias gulp='node_modules/.bin/gulp'
    gulp

If this all works, gulp should assemble all the pieces and open up your browser in
development mode to [localhost](http://localhost:3000)

Production Build
----------------

    # clear out build dir first
    rm -rf build/

    # generate production files, minified and all that jazz
    gulp production
