## ---- include = FALSE----------------------------------------------------
library(ggplot2)
knitr::opts_chunk$set(fig.dpi = 96)

## ------------------------------------------------------------------------
lty <- c("blank", "solid", "dashed", "dotted", "dotdash", 
     "longdash","twodash")
linetypes <- data.frame(
  y = seq_along(lty),
  lty = lty
) 
ggplot(linetypes, aes(0, y)) + 
  geom_segment(aes(xend = 5, yend = y, linetype = lty)) + 
  scale_linetype_identity() + 
  geom_text(aes(label = lty), hjust = 0, nudge_y = 0.2) +
  scale_x_continuous(NULL, breaks = NULL) + 
  scale_y_continuous(NULL, breaks = NULL)

## ------------------------------------------------------------------------
shapes <- data.frame(
  shape = c(0:19, 22, 21, 24, 23, 20),
  x = 0:24 %/% 5,
  y = -(0:24 %% 5)
)
ggplot(shapes, aes(x, y)) + 
  geom_point(aes(shape = shape), size = 5, fill = "red") +
  geom_text(aes(label = shape), hjust = 0, nudge_x = 0.15) +
  scale_shape_identity() +
  expand_limits(x = 4.1) +
  scale_x_continuous(NULL, breaks = NULL) + 
  scale_y_continuous(NULL, breaks = NULL)

## ------------------------------------------------------------------------
sizes <- expand.grid(size = (0:3) * 2, stroke = (0:3) * 2)
ggplot(sizes, aes(size, stroke, size = size, stroke = stroke)) + 
  geom_abline(slope = -1, intercept = 6, colour = "white", size = 6) + 
  geom_point(shape = 21, fill = "red") +
  scale_size_identity()

## ------------------------------------------------------------------------
df <- data.frame(x = 1, y = 3:1, family = c("sans", "serif", "mono"))
ggplot(df, aes(x, y)) + 
  geom_text(aes(label = family, family = family))

## ------------------------------------------------------------------------
just <- expand.grid(hjust = c(0, 0.5, 1), vjust = c(0, 0.5, 1))
just$label <- paste0(just$hjust, ", ", just$vjust)

ggplot(just, aes(hjust, vjust)) +
  geom_point(colour = "grey70", size = 5) + 
  geom_text(aes(label = label, hjust = hjust, vjust = vjust))

