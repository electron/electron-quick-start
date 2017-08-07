/*
 * markdown_rstubs.h
 * 
 * Copyright (C) 2009-2013 by RStudio, Inc.
 * 
 * This program is licensed to you under the terms of version 2 of the
 * GNU General Public License. This program is distributed WITHOUT ANY
 * EXPRESS OR IMPLIED WARRANTY, INCLUDING THOSE OF NON-INFRINGEMENT,
 * MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. Please refer to the
 * GPL (http://www.gnu.org/licenses/gpl-2.0.txt) for more details.
 *
 */

#ifndef MARKDOWN_RSTUBS
#define MARKDOWN_RSTUBS

#include <Rinternals.h>
#include <R_ext/Rdynload.h>
#include "markdown.h"

#ifdef __cplusplus
extern "C" {
#endif

/* bufgrow: increasing the allocated size to the given value */
int rstub_bufgrow(struct buf *, size_t);
#define bufgrow rstub_bufgrow

/* bufnew: allocation of a new buffer */
struct buf *rstub_bufnew(size_t) __attribute__ ((malloc));
#define bufnew rstub_bufnew

/* bufnullterm: NUL-termination of the string array (making a C-string) */
const char *rstub_bufcstr(struct buf *);
#define bufcstr rstub_bufcstr

/* bufprefix: compare the beginning of a buffer with a string */
int rstub_bufprefix(const struct buf *buf, const char *prefix);
#define bufprefix rstub_bufprefix

/* bufput: appends raw data to a buffer */
void rstub_bufput(struct buf *, const void *, size_t);
#define bufput rstub_bufput

/* bufputs: appends a NUL-terminated string to a buffer */
void rstub_bufputs(struct buf *, const char *);
#define bufputs rstub_bufputs

/* bufputc: appends a single char to a buffer */
void rstub_bufputc(struct buf *, int);
#define bufputc rstub_bufputc

/* bufrelease: decrease the reference count and free the buffer if needed */
void rstub_bufrelease(struct buf *);
#define bufrelease rstub_bufrelease

/* bufreset: frees internal data of the buffer */
void rstub_bufreset(struct buf *);
#define bufreset rstub_bufreset

/* bufslurp: removes a given number of bytes from the head of the array */
void rstub_bufslurp(struct buf *, size_t);
#define bufslurp rstub_bufslurp

/* bufprintf: formatted printing to a buffer */
void rstub_bufprintf(struct buf *, const char *, ...) __attribute__ ((format (printf, 2, 3)));
#define bufprintf rstub_bufprintf

extern int
rstub_sd_autolink_issafe(const uint8_t *link, size_t link_len);
#define sd_autolink_issafe rstub_sd_autolink_issafe

extern size_t
rstub_sd_autolink__www(size_t *rewind_p, struct buf *link, uint8_t *data,
                     size_t offset, size_t size);
#define sd_autolink__www rstub_sd_autolink__www

extern size_t
rstub_sd_autolink__email(size_t *rewind_p, struct buf *link, uint8_t *data,
                       size_t offset, size_t size);
#define sd_autolink__email rstub_sd_autolink__email

extern size_t
rstub_sd_autolink__url(size_t *rewind_p, struct buf *link, uint8_t *data,
                     size_t offset, size_t size);
#define sd_autolink__url rstub_sd_autolink__url

extern struct sd_markdown *
rstub_sd_markdown_new(
	unsigned int extensions,
	size_t max_nesting,
	const struct sd_callbacks *callbacks,
	void *opaque);
#define sd_markdown_new rstub_sd_markdown_new

extern void
rstub_sd_markdown_render(struct buf *ob, const uint8_t *document, size_t doc_size,
                       struct sd_markdown *md);
#define sd_markdown_render rstub_sd_markdown_render

extern void
rstub_sd_markdown_free(struct sd_markdown *md);
#define sd_markdown_free rstub_sd_markdown_free

extern void
rstub_sd_version(int *major, int *minor, int *revision);
#define sd_version rstub_sd_version

struct rmd_renderer {
   char *name;
   Rboolean (*render)(struct buf *,struct buf *, SEXP, SEXP);
};

Rboolean rstub_rmd_register_renderer(struct rmd_renderer *);
#define rmd_register_renderer rstub_rmd_register_renderer

Rboolean rstub_rmd_renderer_exists(const char *);
#define rmd_renderer_exists rstub_rmd_renderer_exists

Rboolean rstub_rmd_buf_to_output(struct buf *, SEXP, SEXP *);
#define rmd_buf_to_output rstub_rmd_buf_to_output

Rboolean rstub_rmd_input_to_buf(SEXP, SEXP, struct buf *);
#define rmd_input_to_buf rstub_rmd_input_to_buf

#ifdef __cplusplus
}
#endif

#endif // MARKDOWN_RSTUBS
