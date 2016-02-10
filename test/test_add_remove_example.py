#!/usr/bin/env python
# -*- coding: utf-8 -*-
import pyflann
import numpy as np


def get_flann_params(algorithm='kdtree', **kwargs):
    r"""
    Returns flann params that are relvant tothe algorithm

    Args:
        algorithm (str): (default = 'kdtree')

    Returns:
        dict: flann_params

    References:
        http://www.cs.ubc.ca/research/flann/uploads/FLANN/flann_manual-1.8.4.pdf
    """
    _valid_algos = ['linear', 'kdtree', 'kmeans', 'composite', 'kdtree_single']
    _centersinit_options = ['random', 'gonzales', 'kmeanspp', ]
    # Search params (for all algos)
    assert algorithm in _valid_algos, 'invalid algo'
    flann_params = {'algorithm': algorithm}
    if algorithm != 'linear':
        flann_params.update({'random_seed': -1})
    if algorithm in ['kdtree', 'composite']:
        # kdtree index parameters
        flann_params.update({
            'algorithm': _valid_algos[1],
            'trees': 4,
            'checks': 32,  # how many leafs (features) to check in one search
        })
    elif algorithm in ['kmeans', 'composite']:
        # Kmeans index parametrs
        flann_params.update({
            'branching': 32,
            'iterations': 5,
            'centers_init': _centersinit_options[2],
            'cb_index': 0.5,  # cluster boundary index for searching kmeanms tree
            'checks': 32,  # how many leafs (features) to check in one search
        })
    elif algorithm == 'autotuned':
        flann_params.update({
            'algorithm'        : 'autotuned',
            'target_precision' : 0.01,   # precision desired (used for autotuning, -1 otherwise)
            'build_weight'     : 0.01,   # build tree time weighting factor
            'memory_weight'    : 0.0,    # index memory weigthing factor
            'sample_fraction'  : 0.001,  # what fraction of the dataset to use for autotuning
        })
    elif algorithm == 'lsh':
        flann_params.update({
            'table_number_': 12,
            'key_size_': 20,
            'multi_probe_level_': 2,
        })

    for key, val in kwargs.items():
        assert key in flann_params, 'gave bad parameter=%r' % (key,)
        flann_params[key] = val
    return flann_params


def rand_vecs(num, dim, rng=np.random):
    return (rng.rand(num, dim) * 255).astype(np.uint8)
    #return rng.rand(num, dim)


def dict_str(dict_):
    itemstr_list = ['%s: %r' % (key, val) for key, val in sorted(dict_.items())]
    return '{\n    ' + ('\n    '.join(itemstr_list)) + '\n}'


def report_list(list_, name):
    return '    ' + name + ' = [' + ', '.join([str(r2[0]) for r2 in list_]) + ']'


def add_remove_example():
    # Make determenistic test dataset
    print('+=============================================')
    print('STARTING FLANN EXAMPLE --- ADD / REMOVE POINTS')
    print('+=============================================')
    print('------')
    print('Step 1) Initialize')
    print(' * Create a test dataset and build a neighbor index')

    rng = np.random.RandomState(0)
    data_dim = 128
    num_dpts = 1000
    num_qpts = 15
    num_neighbs = 5

    dataset = rand_vecs(num_dpts, data_dim, rng)
    testset = rand_vecs(num_qpts, data_dim, rng)

    params = get_flann_params(algorithm='kdtree', trees=4, random_seed=42)
    print('params = ' + dict_str(params))

    # Build determenistic flann object
    flann = pyflann.FLANN()
    flann.build_index(dataset, **params)

    print(' * Test search on the initial index')
    # check nearest neighbor search before add
    result1, dists = flann.nn_index(testset, num_neighbs, checks=params['checks'])

    print(' * Neighbor results should be all over the place between 0 and %d' % (num_dpts,))
    print(report_list(result1, 'result1'))

    # check memory
    prev_index_memory = flann.used_memory()
    prev_data_memory = flann.used_memory_dataset()

    print('------')
    print('Step 2) Add new points to the index')
    # Add points
    flann.add_points(testset, 2)

    # check memory after add points
    post_index_memory = flann.used_memory()
    post_data_memory = flann.used_memory_dataset()

    print(' * Check memory usage after add')
    print('    used memory =        before,         after')
    print('     index      =  %d bytes,  %d bytes' % (prev_index_memory,  post_index_memory))
    print('     data       =  %d bytes,  %d bytes' % (prev_data_memory,  post_data_memory))

    print(' * Test search on newly added points against themselves')
    # check nearest neighbor search after add
    result2, _ = flann.nn_index(testset, num_neighbs, checks=params['checks'])

    print(' * Neighbor results should be between %d and %d' % (num_dpts, num_dpts + num_qpts))
    print(report_list(result2, 'result2'))
    assert np.all(result2.T[0] >= num_dpts), 'new points should be found first'
    assert (result2.T[1] == result1.T[0]).sum() > result1.shape[0] / 2, 'most old points should be found next'

    # Remove half of the test points
    print('------')
    print('Step 3) Remove half of the points we just added')
    for id_ in range(num_dpts, num_dpts + num_qpts, 2):
        flann.remove_point(id_)

    result3, _ = flann.nn_index(testset, num_neighbs, checks=params['checks'])
    print(report_list(result3, 'result3'))

    print(' * Check memory usage after remove')
    print('    used memory =  after remove_point')
    print('     index      =  %d bytes' % (flann.used_memory(),))
    print('     data       =  %d bytes' % (flann.used_memory_dataset(),))
    print('Memory does not change because of lazy deletion.')
    print('The indicies of the other datapoints also does not change')

    testset2 = rand_vecs(num_qpts, data_dim, rng)

    print('------')
    print('Step 4) Add another set of new points to the input')
    # Add points after a delete
    flann.add_points(testset2, 2)

    print(' * Check new points against themselves')
    print(' * Results should be greater than %d' % (num_dpts + num_qpts,))
    result4, _ = flann.nn_index(testset2, num_neighbs, checks=params['checks'])
    assert np.all(result4.T[0] >= num_dpts + num_qpts), 'new add points after delete failed'
    print(report_list(result4, 'result4'))

    print(' * Check to make sure old points still work')
    print(' * Results should be less than %d' % (num_dpts + num_qpts,))
    result5, _ = flann.nn_index(testset[1::2], num_neighbs, checks=params['checks'])
    assert np.all(result5.T[0] <= num_dpts + num_qpts), 'odd test points should not have changed'
    print(report_list(result5, 'result5'))

    print(' * Final memory usage')
    print('    used memory =  after remove_point and add')
    print('     index      =  %d bytes' % (flann.used_memory(),))
    print('     data       =  %d bytes' % (flann.used_memory_dataset(),))


if __name__ == '__main__':
    """
    CommandLine:
        python ~/code/flann/test/test_add_remove_example.py
        python test/test_add_remove_example.py
    """
    add_remove_example()
