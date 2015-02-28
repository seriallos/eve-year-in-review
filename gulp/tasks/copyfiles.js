var gulp         = require('gulp');
var browserSync  = require('browser-sync');
var config       = require('../config').copyfiles;

gulp.task('copyfiles', function() {
  return gulp.src(config.src)
    .pipe(gulp.dest(config.dest))
    .pipe(browserSync.reload({stream:true}));
});
