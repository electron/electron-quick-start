// -*- mode: C++; c-indent-level: 4; c-basic-offset: 4; indent-tabs-mode: nil; -*-
//
// Rstreambuf.h: Rcpp R/C++ interface class library -- stream buffer
//
// Copyright (C) 2011 - 2017  Dirk Eddelbuettel, Romain Francois and Jelmer Ypma
//
// This file is part of Rcpp.
//
// Rcpp is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 2 of the License, or
// (at your option) any later version.
//
// Rcpp is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Rcpp.  If not, see <http://www.gnu.org/licenses/>.

#ifndef RCPP__IOSTREAM__RSTREAMBUF_H
#define RCPP__IOSTREAM__RSTREAMBUF_H

#include <cstdio>
#include <streambuf>

namespace Rcpp {

    template <bool OUTPUT>
    class Rstreambuf : public std::streambuf {
    public:
        Rstreambuf(){}

    protected:
        virtual std::streamsize xsputn(const char *s, std::streamsize n );

        virtual int overflow(int c = traits_type::eof() );

        virtual int sync()  ;
    };

    template <bool OUTPUT>
    class Rostream : public std::ostream {
        typedef Rstreambuf<OUTPUT> Buffer ;
        Buffer* buf ;
    public:
        Rostream() :
            std::ostream( new Buffer ),
            buf( static_cast<Buffer*>( rdbuf() ) )
        {}
        ~Rostream() {
            if (buf != NULL) {
                delete buf;
                buf = NULL;
            }
        }
    };
							// #nocov start
    template <> inline std::streamsize Rstreambuf<true>::xsputn(const char *s, std::streamsize num ) {
        Rprintf( "%.*s", num, s ) ;
        return num ;
    }
    template <> inline std::streamsize Rstreambuf<false>::xsputn(const char *s, std::streamsize num ) {
        REprintf( "%.*s", num, s ) ;
        return num ;
    }

    template <> inline int Rstreambuf<true>::overflow(int c ) {
        if (c != traits_type::eof()) {
            char_type ch = traits_type::to_char_type(c);
            return xsputn(&ch, 1) == 1 ? c : traits_type::eof();
        }
        return c;
    }
    template <> inline int Rstreambuf<false>::overflow(int c ) {
        if (c != traits_type::eof()) {
            char_type ch = traits_type::to_char_type(c);
            return xsputn(&ch, 1) == 1 ? c : traits_type::eof();
        }
        return c;
    }

    template <> inline int Rstreambuf<true>::sync(){
        ::R_FlushConsole() ;
        return 0 ;
    }
    template <> inline int Rstreambuf<false>::sync(){
        ::R_FlushConsole() ;
        return 0 ;
    }								// #nocov end
    static Rostream<true>  Rcout;
    static Rostream<false> Rcerr;


}

#endif
