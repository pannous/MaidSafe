// Copyright (c) 2006, 2007 Julio M. Merino Vidal
// Copyright (c) 2008 Ilya Sokolov, Boris Schaeling
// Copyright (c) 2009 Boris Schaeling
// Copyright (c) 2010 Felipe Tanus, Boris Schaeling
// Copyright (c) 2011, 2012 Jeff Flinn, Boris Schaeling
//
// Distributed under the Boost Software License, Version 1.0. (See accompanying
// file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

/**
 * \file boost/process/posix/pipe.hpp
 *
 * Defines a pipe.
 */

#ifndef BOOST_PROCESS_POSIX_PIPE_HPP
#define BOOST_PROCESS_POSIX_PIPE_HPP

namespace boost { namespace process { namespace posix {

struct pipe
{
    int source;
    int sink;

    pipe(int source, int sink) : source(source), sink(sink) {}
};

inline pipe make_pipe(int source, int sink)
{
    return pipe(source, sink);
}

}}}

#endif
