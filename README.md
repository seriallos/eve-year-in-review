EVE Year in Review
==================

Showcase of new character stats for EVE Fanfest 2015

Notes
-----

* By default, the application is entirely client side and so no data is sent to my server.
    * If you choose to share your stats, your data will be stored on my server so that it
      can be retrieved later as a permalink.  My app/server do not have access to your
      credentials, only the data retrieved and possibly an access token with limited
      rights.
    * Google analytics is used for basic traffic tracking.
* https://sisilogin.testeveonline.com/ is CCP's Sisi Single Sign On site.  It's
  trustworthy.  Once the API is available from TQ Crest this app will be switched over.
  Sisi is just being used temporarily until it's rolled out for real.
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
