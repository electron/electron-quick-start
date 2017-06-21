// -*- mode: C++; c-indent-level: 4; c-basic-offset: 4; tab-width: 8 -*-
//
// Module_generated_class_factory.h: Rcpp R/C++ interface class library -- alternative way to declare constructors
//
// Copyright (C) 2012 Dirk Eddelbuettel and Romain Francois
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

#ifndef Rcpp_Module_generated_class_factory_h
#define Rcpp_Module_generated_class_factory_h

    template <
        typename U0,
        typename U1,
        typename U2,
        typename U3,
        typename U4,
        typename U5,
        typename U6
    >
    self& factory( Class* (*fun)(U0,U1,U2,U3,U4,U5,U6), const char* docstring = 0, ValidConstructor valid = &yes_arity<7> ){
        AddFactory( new Factory_7<Class,U0,U1,U2,U3,U4,U5,U6>(fun) , valid, docstring ) ;
        return *this ;
    }

    template <
        typename U0,
        typename U1,
        typename U2,
        typename U3,
        typename U4,
        typename U5
    >
    self& factory( Class* (*fun)(U0,U1,U2,U3,U4,U5), const char* docstring = 0, ValidConstructor valid = &yes_arity<6> ){
        AddFactory( new Factory_6<Class,U0,U1,U2,U3,U4,U5>(fun) , valid, docstring ) ;
        return *this ;
    }

    template <
        typename U0,
        typename U1,
        typename U2,
        typename U3,
        typename U4
    >
    self& factory( Class* (*fun)(U0,U1,U2,U3,U4), const char* docstring = 0, ValidConstructor valid = &yes_arity<5>){
        AddFactory( new Factory_5<Class,U0,U1,U2,U3,U4>(fun) , valid, docstring ) ;
        return *this ;
    }

    template <
        typename U0,
        typename U1,
        typename U2,
        typename U3
    >
    self& factory( Class* (*fun)(U0,U1,U2,U3), const char* docstring="", ValidConstructor valid = &yes_arity<4>){
        AddFactory( new Factory_4<Class,U0,U1,U2,U3>(fun) , valid, docstring ) ;
        return *this ;
    }


    template <
        typename U0,
        typename U1,
        typename U2
    >
    self& factory( Class* (*fun)(U0,U1,U2), const char* docstring="",  ValidConstructor valid = &yes_arity<3>){
        AddFactory( new Factory_3<Class,U0,U1,U2>(fun) , valid, docstring ) ;
        return *this ;
    }

    template <
        typename U0,
        typename U1
    >
    self& factory( Class* (*fun)(U0,U1), const char* docstring="", ValidConstructor valid = &yes_arity<2>){
        AddFactory( new Factory_2<Class,U0,U1>(fun) , valid, docstring ) ;
        return *this ;
    }

    template <
        typename U0
    >
    self& factory( Class* (*fun)(U0), const char* docstring="", ValidConstructor valid = &yes_arity<1>){
        AddFactory( new Factory_1<Class,U0>(fun) , valid, docstring ) ;
        return *this ;
    }

    self& factory( Class* (*fun)(void), const char* docstring="", ValidConstructor valid = &yes_arity<0>){
        AddFactory( new Factory_0<Class>(fun), valid , docstring) ;
        return *this ;
    }

#endif
