test01 <- function() {
  f <- foreach(i=1:3, .packages='foo') %:% foreach(j=1:3, .packages='bar')
  checkEquals(sort(f$packages), c('bar', 'foo'))

  f <- foreach(i=1:3, .packages='foo') %:% foreach(j=1:3, .packages=c('bar', 'foo'))
  checkEquals(sort(f$packages), c('bar', 'foo'))

  f <- foreach(i=1:3, .packages='foo') %:% foreach(j=1:3, .packages=c('bar', 'baz'))
  checkEquals(sort(f$packages), c('bar', 'baz', 'foo'))

  f <- foreach(i=1:3, .packages='foo') %:% foreach(j=1:3)
  checkEquals(sort(f$packages), c('foo'))
}

test02 <- function() {
  f <- foreach(i=1:3, .export='foo') %:% foreach(j=1:3, .export='bar')
  checkEquals(sort(f$export), c('bar', 'foo'))

  f <- foreach(i=1:3, .export='foo') %:% foreach(j=1:3, .export=c('bar', 'foo'))
  checkEquals(sort(f$export), c('bar', 'foo'))

  f <- foreach(i=1:3, .export='foo') %:% foreach(j=1:3, .export=c('bar', 'baz'))
  checkEquals(sort(f$export), c('bar', 'baz', 'foo'))

  f <- foreach(i=1:3, .export='foo') %:% foreach(j=1:3)
  checkEquals(sort(f$export), c('foo'))

  f <- foreach(i=1:3, .noexport='foo') %:% foreach(j=1:3, .noexport=c('bar', 'foo'))
  checkEquals(sort(f$noexport), c('bar', 'foo'))

  f <- foreach(i=1:3, .noexport='foo') %:% foreach(j=1:3, .noexport=c('bar', 'baz'))
  checkEquals(sort(f$noexport), c('bar', 'baz', 'foo'))

  f <- foreach(i=1:3, .noexport='foo') %:% foreach(j=1:3)
  checkEquals(sort(f$noexport), c('foo'))
}
