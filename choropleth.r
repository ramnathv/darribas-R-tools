##################################
# Choropleth: thematic maps in R #
##################################

# Author: Daniel Arribas-Bel <daniel.arribas.bel@gmail.com>
# Copyright 2010 by Daniel Arribas-Bel 
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    See: <http://creativecommons.org/licenses/GPL/2.0/> or <http://www.gnu.org/licenses/>

library(maptools)
library(spatial)
library(RColorBrewer)
library(classInt)

choropleth <- function(shp, field, png=FALSE, bins=FALSE, bgLayer=FALSE,
        colPal="Blues", style="hclust", lwd=0.5, title='', sub='', xlab='',
        ylab='', legend=TRUE, font=4, tcol='black', texto=''){
            # If not 'bins' -> categorical data
            poly <- readShapeSpatial(shp, force_ring=TRUE)
            attach(poly@data, warn.conflicts=FALSE)
            data <- get(field)
            if(bins==FALSE){
                bins <- length(unique(get(field)))
                colCode <- colCoder(poly, field, colPal)
                leyenda <- colCode$legend
                fill <- colCode$paleta
                colCode <- colCode$colVec
                } else {
                colors <- brewer.pal(bins, colPal)
                class = classIntervals(data, bins, style)
                colCode = findColours(class, colors, digits=4)
                leyenda = names(attr(colCode, "table"))
                fill = attr(colCode, "palette")
                }
            detach(poly@data)
            #
            if(png!=FALSE){
                png(png, width=960, height=960, bg="white")
                }
            if(bgLayer!=FALSE){
                polyBg <- readShapeSpatial(bgLayer, force_ring=TRUE)
                plot(polyBg, lwd=lwd)
                plot(poly, add=TRUE, col=colCode, lwd=lwd)
                } else {
                plot(poly, col=colCode, lwd=lwd)
                }
            title(main=title, sub=sub, xlab=xlab, ylab=ylab, cex.main=font,
            col.main=tcol, cex.sub=font, cex.lab=font)
            if(texto!=''){
                text(-1, -1, texto)
                }
            if(legend==TRUE){legend("topleft", legend=leyenda, fill=fill, cex=0.75, bty="n")}
            if(png!=FALSE){
                dev.off()
                }
            "Map created"
            }

colCoder <- function(poly, var, colPal){
            attach(poly@data, warn.conflicts=FALSE)
            uniques <- unique(get(var))
            paleta <- brewer.pal(length(uniques), colPal)
            colVec <- mat.or.vec(length(get(var)), 1)
            for(row in seq(length(get(var)))){
                ind <- which(uniques == get(var)[row])
                colVec[row] <- paleta[ind]
                }
            detach(poly@data)
            res <- list(colVec=colVec, legend=uniques, paleta=paleta)
            res
            }


