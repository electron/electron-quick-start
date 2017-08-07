// Boost.Geometry

// Copyright (c) 2007-2012 Barend Gehrels, Amsterdam, the Netherlands.

// This file was modified by Oracle on 2014.
// Modifications copyright (c) 2014 Oracle and/or its affiliates.

// Contributed and/or modified by Adam Wulkiewicz, on behalf of Oracle

// Use, modification and distribution is subject to the Boost Software License,
// Version 1.0. (See accompanying file LICENSE_1_0.txt or copy at
// http://www.boost.org/LICENSE_1_0.txt)

#ifndef BOOST_GEOMETRY_STRATEGIES_AGNOSTIC_SIDE_BY_AZIMUTH_HPP
#define BOOST_GEOMETRY_STRATEGIES_AGNOSTIC_SIDE_BY_AZIMUTH_HPP

#include <boost/mpl/if.hpp>
#include <boost/type_traits.hpp>
#include <boost/core/ignore_unused.hpp>

#include <boost/geometry/core/cs.hpp>
#include <boost/geometry/core/access.hpp>
#include <boost/geometry/core/radian_access.hpp>

#include <boost/geometry/algorithms/detail/azimuth.hpp>

#include <boost/geometry/util/math.hpp>
#include <boost/geometry/util/promote_floating_point.hpp>
#include <boost/geometry/util/select_calculation_type.hpp>

#include <boost/geometry/strategies/side.hpp>
//#include <boost/geometry/strategies/concepts/side_concept.hpp>


namespace boost { namespace geometry
{


namespace strategy { namespace side
{

/*!
\brief Check at which side of a segment a point lies
         left of segment (> 0), right of segment (< 0), on segment (0)
\ingroup strategies
\tparam Model Reference model of coordinate system.
\tparam CalculationType \tparam_calculation
 */
template <typename Model, typename CalculationType = void>
class side_by_azimuth
{
public:
    side_by_azimuth(Model const& model = Model())
        : m_model(model)
    {}

    template <typename P1, typename P2, typename P>
    inline int apply(P1 const& p1, P2 const& p2, P const& p)
    {
        typedef typename promote_floating_point
            <
                typename select_calculation_type_alt
                    <
                        CalculationType,
                        P1, P2, P
                    >::type
            >::type calc_t;

        calc_t d1 = 0.001;
        calc_t crs_AD = geometry::detail::azimuth<calc_t>(p1, p, m_model);
        calc_t crs_AB = geometry::detail::azimuth<calc_t>(p1, p2, m_model);
        calc_t XTD = asin(sin(d1) * sin(crs_AD - crs_AB));

        return math::equals(XTD, 0) ? 0 : XTD < 0 ? 1 : -1;
    }

private:
    Model m_model;
};

}} // namespace strategy::side


}} // namespace boost::geometry


#endif // BOOST_GEOMETRY_STRATEGIES_AGNOSTIC_SIDE_BY_AZIMUTH_HPP
