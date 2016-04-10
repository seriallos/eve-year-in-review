EVE Year in Review
==================

Showcase of new character stats for EVE Fanfest 2015

Notes
-----

* The application is entirely client side - none of your data is saved on my
  server.
* Google analytics is used for basic traffic tracking.
* The site uses CCP's single sign on for account validation so your credentials
  never get near my server/code.
* Built primarily using
    * React
    * d3
    * Bootstrap
    * Bit of jQuery

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
