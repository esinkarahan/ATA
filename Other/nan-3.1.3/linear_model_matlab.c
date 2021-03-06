/*

$Id$
Copyright (c) 2007-2009 The LIBLINEAR Project.
Copyright (c) 2010 Alois Schloegl <alois.schloegl@gmail.com>
This function is part of the NaN-toolbox
http://pub.ist.ac.at/~schloegl/matlab/NaN/

This code was extracted from liblinear-1.51 in Jan 2010 and 
modified for the use with Octave 

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, see <http://www.gnu.org/licenses/>.

*/


#include <stdlib.h>
#include <string.h>
#if defined(HAVE_EXTERNAL_LIBLINEAR)
  #include <linear.h>
#else
  #include "linear.h"
#endif
#include "mex.h"

#ifdef tmwtypes_h
  #if (MX_API_VER<=0x07020000)
    typedef int mwSize;
  #endif 
#endif 

#define Malloc(type,n) (type *)malloc((n)*sizeof(type))

#define NUM_OF_RETURN_FIELD 6

static const char *field_names[] = {
	"Parameters",
	"nr_class",
	"nr_feature",
	"bias",
	"Label",
	"w",
};

#ifdef __cplusplus
extern "C" {
#endif

const char *model_to_matlab_structure(mxArray *plhs[], struct model *model_)
{
	size_t i;
	size_t nr_w;
	double *ptr;
	mxArray *return_model, **rhs;
	int out_id = 0;
	size_t n, w_size;

	rhs = (mxArray **)mxMalloc(sizeof(mxArray *)*NUM_OF_RETURN_FIELD);

	/* Parameters */
	/* for now, only solver_type is needed */
	rhs[out_id] = mxCreateDoubleMatrix(1, 1, mxREAL);
	ptr = mxGetPr(rhs[out_id]);
	ptr[0] = model_->param.solver_type;
	out_id++;

	/* nr_class */
	rhs[out_id] = mxCreateDoubleMatrix(1, 1, mxREAL);
	ptr = mxGetPr(rhs[out_id]);
	ptr[0] = model_->nr_class;
	out_id++;

	if(model_->nr_class==2 && model_->param.solver_type != MCSVM_CS)
		nr_w=1;
	else
		nr_w=model_->nr_class;

	/* nr_feature */
	rhs[out_id] = mxCreateDoubleMatrix(1, 1, mxREAL);
	ptr = mxGetPr(rhs[out_id]);
	ptr[0] = model_->nr_feature;
	out_id++;

	/* bias */
	rhs[out_id] = mxCreateDoubleMatrix(1, 1, mxREAL);
	ptr = mxGetPr(rhs[out_id]);
	ptr[0] = model_->bias;
	out_id++;

	if(model_->bias>=0)
		n=model_->nr_feature+1;
	else
		n=model_->nr_feature;

	w_size = n;
	/* Label */
	if(model_->label)
	{
		rhs[out_id] = mxCreateDoubleMatrix(model_->nr_class, 1, mxREAL);
		ptr = mxGetPr(rhs[out_id]);
		for(i = 0; i < model_->nr_class; i++)
			ptr[i] = model_->label[i];
	}
	else
		rhs[out_id] = mxCreateDoubleMatrix(0, 0, mxREAL);
	out_id++;

	/* w */
	rhs[out_id] = mxCreateDoubleMatrix(nr_w, w_size, mxREAL);
	ptr = mxGetPr(rhs[out_id]);
	for(i = 0; i < w_size*nr_w; i++)
		ptr[i]=model_->w[i];
	out_id++;

	/* Create a struct matrix contains NUM_OF_RETURN_FIELD fields */
	return_model = mxCreateStructMatrix(1, 1, NUM_OF_RETURN_FIELD, field_names);

	/* Fill struct matrix with input arguments */
	for(i = 0; i < NUM_OF_RETURN_FIELD; i++)
		mxSetField(return_model,0,field_names[i],mxDuplicateArray(rhs[i]));
	/* return */
	plhs[0] = return_model;
	mxFree(rhs);

	return NULL;
}

const char *matlab_matrix_to_model(struct model *model_, const mxArray *matlab_struct)
{
	size_t i, num_of_fields;
	size_t nr_w;
	double *ptr;
	int id = 0;
	size_t n, w_size;
	mxArray **rhs;

	num_of_fields = mxGetNumberOfFields(matlab_struct);
	rhs = (mxArray **) mxMalloc(sizeof(mxArray *)*num_of_fields);

	for(i=0;i<num_of_fields;i++)
		rhs[i] = mxGetFieldByNumber(matlab_struct, 0, i);

	model_->nr_class=0;
	nr_w=0;
	model_->nr_feature=0;
	model_->w=NULL;
	model_->label=NULL;

	/* Parameters */
	ptr = mxGetPr(rhs[id]);
	model_->param.solver_type = (int)ptr[0];
	id++;

	/* nr_class */
	ptr = mxGetPr(rhs[id]);
	model_->nr_class = (int)ptr[0];
	id++;

	if(model_->nr_class==2 && model_->param.solver_type != MCSVM_CS)
		nr_w=1;
	else
		nr_w=model_->nr_class;

	/* nr_feature */
	ptr = mxGetPr(rhs[id]);
	model_->nr_feature = (int)ptr[0];
	id++;

	/* bias */
	ptr = mxGetPr(rhs[id]);
	model_->bias = (int)ptr[0];
	id++;

	if(model_->bias>=0)
		n=model_->nr_feature+1;
	else
		n=model_->nr_feature;
	w_size = n;

	ptr = mxGetPr(rhs[id]);
	model_->label=Malloc(int, model_->nr_class);
	for(i=0; i<model_->nr_class; i++)
		model_->label[i]=(int)ptr[i];
	id++;

	ptr = mxGetPr(rhs[id]);
	model_->w=Malloc(double, w_size*nr_w);
	for(i = 0; i < w_size*nr_w; i++)
		model_->w[i]=ptr[i];
	id++;
	mxFree(rhs);

	return NULL;
}

#ifdef __cplusplus
}
#endif

