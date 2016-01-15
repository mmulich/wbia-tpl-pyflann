#!/usr/bin/env python
# -*- coding: utf-8 -*-
import pyflann
import numpy as np


def rand_vecs(num, dim, rng=np.random):
    return (rng.rand(num, dim) * 255).astype(np.uint8)
    #return rng.rand(num, dim)


def dict_str(dict_):
    itemstr_list = ['%s: %r' % (key, val) for key, val in sorted(dict_.items())]
    return '{\n    ' + ('\n    '.join(itemstr_list)) + '\n}'


def test_add_and_remove():
    # Make determenistic test dataset
    rng = np.random.RandomState(0)
    data_dim = 128
    num_dpts = 1000
    num_qpts = 100
    num_neighbs = 5

    dataset = rand_vecs(num_dpts, data_dim, rng)
    testset = rand_vecs(num_qpts, data_dim, rng)

    # Build determenistic flann object
    flann = pyflann.FLANN()
    params = flann.build_index(dataset, algorithm='kdtree', trees=4, random_seed=42)

    print('params = ' + dict_str(params))

    # check nearest neighbor search before add
    result1, dists = flann.nn_index(testset, num_neighbs, checks=params['checks'])

    print('Neighbor results should be all over the place')
    print(','.join([str(r1[0]) for r1 in result1]))

    # check memory
    prev_index_memory = flann.used_memory()
    prev_data_memory = flann.used_memory_dataset()
    prev_total = prev_index_memory + prev_data_memory

    # Add points
    flann.add_points(testset, 2)

    # check memory after add points
    post_index_memory = flann.used_memory()
    post_data_memory = flann.used_memory_dataset()
    post_total = post_index_memory + post_index_memory

    print('used memory =        before,         after')
    print(' index      =  %d bytes,  %d bytes' % (prev_index_memory,  post_index_memory))
    print(' data       =  %d bytes,  %d bytes' % (prev_data_memory,  post_data_memory))
    print(' total      =  %d bytes,  %d bytes' % (prev_total, post_total))

    # check nearest neighbor search after add
    result2, _ = flann.nn_index(testset, num_neighbs, checks=params['checks'])

    print('Neighbor results should be between %d and %d' % (num_dpts, num_dpts + num_qpts))
    print(','.join([str(r2[0]) for r2 in result2]))
    assert np.all(result2.T[0] >= num_dpts), 'new points should be found first'
    assert (result2.T[1] == result1.T[0]).sum() > result1.shape[0] / 2, 'most old points should be found next'

    # Remove half of the test points
    for id_ in range(num_dpts, num_dpts + num_qpts, 2):
        flann.remove_point(id_)

    result3, _ = flann.nn_index(testset, num_neighbs, checks=params['checks'])

    print('used memory =  after remove_point')
    print(' index      =  %d bytes' % (flann.used_memory(),))
    print(' data       =  %d bytes' % (flann.used_memory_dataset(),))

    testset2 = rand_vecs(num_qpts, data_dim, rng)

    # Add points after a delete
    flann.add_points(testset2, 2)

    print('Results should be after %d' % (num_dpts + num_qpts,))
    result4, _ = flann.nn_index(testset2, num_neighbs, checks=params['checks'])
    print(','.join([str(r2[0]) for r2 in result4]))
    assert np.all(result4.T[0] >= num_dpts + num_qpts), 'new add points after delete failed'

    print('Results should be before %d' % (num_dpts + num_qpts,))
    result5, _ = flann.nn_index(testset[1::2], num_neighbs, checks=params['checks'])
    assert np.all(result5.T[0] <= num_dpts + num_qpts), 'odd test points should not have changed'
    print(','.join([str(r2[0]) for r2 in result5]))

    print('used memory =  after remove_point and add')
    print(' index      =  %d bytes' % (flann.used_memory(),))
    print(' data       =  %d bytes' % (flann.used_memory_dataset(),))


if __name__ == '__main__':
    """
    CommandLine:
        python test/test_add_remove.py
    """
    test_add_and_remove()
