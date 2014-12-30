Randomly assorted routines for projective reconstruction
--------------------------------------------------------

This is just a collection of various MATLAB routines that I happened to
have lying around. They should also work under Octave, except for the
bundle adjustment which uses sparse Matlab matrices. You can use and
distribute them freely on the understanding that this is entirely
unmaintained as-is code. I make no guarantee of correctness.

The routines were written at various times for various purposes, but
mainly for rapid prototyping of new ideas and variants of methods.  All
of them are very far from ``finished production code'' (if such a thing
is even possible in Matlab). I have made no attempt to tidy them, unify
them, improve the commenting, or even check whether they still work
properly.  However, I believe that each of them did work correctly at
one stage, so at worst they shouldn't be too far from correct.  Many
short-cuts were taken to simplify coding: inefficient Matlab-isms,
unprofessional convergence testing and normalization methods, algebraic
rather than statistical error metrics, etc. In short ``your mileage may
vary''.

To see how to call the various methods, look at the test routines tst_*.
These are all just quick hacks used for debugging while the code was
being written. They should generate algebraically valid data, but they
make no (systematic) attempt to make it physically realistic
(e.g. deleting points that project outside image boundaries, etc).  In
general they generate random data, run the selected routines, and
evaluate some sort of algebraic error score for the output.

tst_proj_recons.m, proj_recons_fsvd.m, ...
------------------------------------------

The Sturm-Triggs ECCV'96 projective factorization method (estimate
depths once using fundamental matrices), and a few variants on it for
incrementally adding further images.  These are ``tutorial'' routines
written as deliverables for a European project. They are fairly well
commented, but they were intentionally designed to be ``the simplest
implementation possible'', so all refinements are omitted.  These
routines weren't developed any further on the project, as it turned out
that the industrial partners weren't at all interested in projective
techniques (I know of almost none who are, in fact).  The original
versions of most of these methods (whose results were reported in the
original ECCV'96 and CVPR'97 papers) were in C, so these are
reimplementations (but not refinements).

All of these methods are essentially closed form solutions, not
iterative bundle-adjustment-like ones (if we count direct matrix
factorizations like SVD as non-iterative). Sorry, I don't have a Matlab
implementation of factorization with iterative depth recovery, only the
original C one which can not be easily extracted from its C environment.


tst_pp_recons.m, proj_recons_ppsvd.m
------------------------------------

A version of my ECCV'2000 plane+parallax rank 1 projective factorization
method. This was written just to try out the idea. The code is fairly
well commented but a little hacked-around. Again, everything is as
simple as possible.

tst_bundle.m, bundle_*.m
------------------------

This is the-part-that-got-written of an attempt at a general bundle
adjustment code in Matlab. It stalled because I ran out of time, but in
any case I was dissatisfied with various Matlab limitations. If I try
this again I'll do it in C. The implementation quality is very
variable. It runs, but it is unfinished as-is code.  Some parts are
fairly sound, others are just hacks used while debugging other
pieces. It was designed to allow different feature and camera types, but
only one parametrization each of points and general projective cameras
got implemented, neither very professionally.

It uses Matlab sparse matrices for the Jacobian and Hessian, and sparse
Cholesky decomposition with several variable ordering policies.  One of
the aims of this was to investigate performances for various typical
sparsity patterns, but it turns out that Matlab sparse matrices are so
inefficient that it becomes excruciatingly slow for large
problems. (Specifically, forming H = J'*J is slow for large matrices,
and J can not be decomposed directly as there is no sparse QR).  Gauge
freedom is also not handled professionally.

The main routine is do_bundle.m. The matrix format used to pass
parameters and observations to this bundle routine is very ugly. I
didn't want to use Matlab `structures' as they are extremely slow, and
Octave (which is my usual environment) doesn't support them. See
bundle_scene.m and bundle_jacobian.m for how to set up these matrices,
and bundle_pred_step.m for the supported step prediciton (linearized
solution) methods.

---------------------------------------------------------------------
That's all folks, as the bunny says.
Bill Triggs, February 2001
