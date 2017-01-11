from django.views import generic
from django.core.urlresolvers import reverse,reverse_lazy
from django.shortcuts import render, redirect, get_object_or_404
from django.utils.lorem_ipsum import words
from django.views.generic.base import TemplateView
from django.views.generic import CreateView
from django.views.generic import ListView
from django.views.generic import UpdateView
from django.views.generic import DeleteView
from django.views.generic import DetailView
from django.views.generic import FormView
from django.contrib import messages
from django.shortcuts import render_to_response
from django.http import HttpResponseRedirect
import datetime

from django_tables2 import MultiTableMixin, RequestConfig, SingleTableView

# Create your views here.
from trip.models import Trip_Commitment_Dashboard,Trip,Trip_current_payment_due,Trip_Commitment,Payment,Student,Student_Fund_Raiser,Trip_Fund_Raiser_Profit,Trip_Fund_Raiser_Detail,Trip_Fund_Raiser_Item_Detail
from trip.tables import (ThemedTrip_CommitmentTable,ThemedStudent_Fund_RaiserTable,ThemedFund_Raiser_DetailTable,Fund_Raiser_Item_DetailTable)
#from trip.forms import PaymentForm
from trip.forms import CreatePaymentForm,StudentForm,TripCommitmentForm,TripCommitmentFormSet

# Used to populate header of Trip Commitment Dashboard, remember to register in settings.py context_processor
def trip(request):
    return render("trip_commitment_list.html",context_instance=RequestContext(request))

# Used to populate header of Trip Commitment Dashboard
def current_payment_date(request):
    return render("trip_commitment_list.html",context_instance=RequestContext(request))

def student_name(request):
    return render("list_payment.html",context_instance=RequestContext(request))

def current_payment_date(request):
    return render("list_payment.html",context_instance=RequestContext(request))

def payments(request):
    return render("edit_payment.html", context_instance=RequestContext(request))

class HomePageView(TemplateView): 
    template_name = 'home.html' 

    def get_context_data(self, **kwargs): 
        context = super(HomePageView, self).get_context_data(**kwargs) 
        messages.info(self.request, 'hello http://example.com') 
        return context 

class FormsetMixin(object):
    object=None

    def get(self,request, *args, **kwargs):
        if getattr(self,'is_update_view', False):
            self.object = self.get_object()
        form_class = self.get_form_class()
        form = self.get_form(form_class)
        formset_class = self.get_formset_class()
        formset = self.get_formset(formset_class)
        return self.render_to_response(self.get_context_data(form=form,formset=formset))

    def post(self, request, *args, **kwargs):
        if getattr(self, 'is_update_view', False):
            self.object = self.get_object()
        form_class = self.get_form_class()
        form = self.get_form(form_class)
        formset_class = self.get_formset_class()
        formset = self.get_formset(formset_class)
        if form.is_valid() and formset.is_valid():
            return self.form_valid(form, formset)
        else:
            return self.form_invalid(form, formset)

    def get_formset_class(self):
        return self.formset_class

    def get_formset(self, formset_class):
        return formset_class(**self.get_formset_kwargs())

    def get_formset_kwargs(self):
        kwargs = {
            'instance': self.object
        }
        if self.request.method in ('POST', 'PUT'):
            kwargs.update({
                'data': self.request.POST,
                'files': self.request.FILES,
            })
        return kwargs

    def form_valid(self, form, formset):
        self.object = form.save()
        formset.instance = self.object
        formset.save()
        return redirect(self.object.get_absolute_url())

    def form_invalid(self, form, formset):
        return self.render_to_response(self.get_context_data(form=form, formset=formset))


class StudentCreateView(FormsetMixin, CreateView):
    template_name = 'student_and_trip_form.html'
    model = Student
    form_class = StudentForm
    formset_class = TripCommitmentFormSet


class StudentUpdateView(FormsetMixin, UpdateView):
    template_name = 'student_and_trip_form.html'
    is_update_view = True
    model = Student
    form_class = StudentForm
    formset_class = TripCommitmentFormSet


class TripCommitmentList(ListView):
    model = Trip_Commitment


class TripCommitmentDetail(DetailView):
    model = Trip_Commitment


class StudentList(ListView):
    model = Student


class StudentDetail(DetailView):
    model = Student
    

class CreatePaymentView(CreateView):
    model = Payment
    template_name='edit_payment.html'
    fields='__all__'
    def get_success_url(self):
        return reverse('payment-new')
    def get_context_data(self, ** kwargs):
        context = super(CreatePaymentView, self).get_context_data(**kwargs)
        context['action'] = reverse('payment-new')
        return context

class UpdatePaymentView(UpdateView):
    model = Payment
    template_name = 'edit_payment.html'
    fields='__all__'
    def get_success_url(self):
        return reverse('createlistpaymentview',kwargs={'id':self.get_object().trip_commitment_id})
    def get_context_data(self, **kwargs):
        context=super(UpdatePaymentView, self).get_context_data(**kwargs)
        context['action'] = reverse('payment-edit',kwargs={'pk': self.get_object().id})
        return context

class CreateListPaymentView(CreateView):
    form_class = CreatePaymentForm
    model = Payment
    template_name = 'createlistpaymentview.html'
    def form_valid(self, form):
        print( "\n\n\nform_valid\n\n\n")
        pmt = form.save(commit=False)
        pmt.trip_commitment_id = self.kwargs['id']
        pmt.save()
        return redirect(pmt.get_absolute_url())
    def get_context_data(self, **kwargs):
        kwargs['object_list'] = Payment.objects.filter(trip_commitment_id=self.kwargs['id']).order_by('payment_date')
        return super(CreateListPaymentView, self).get_context_data(**kwargs)
    def get_success_url(self):
        return reverse('createlistpaymentview',kwargs={'id':self.object.trip_commitment_id})
        
class ListFund_RaiserView(ListView):
    table_class = ThemedStudent_Fund_RaiserTable
    template_name = 'list_student_fund_raiser.html'
    model = Trip_Fund_Raiser_Profit
    def get_queryset(self, **kwargs):
        return Trip_Fund_Raiser_Profit.objects.filter(trip_commitment_id=self.kwargs['id'])

class ListFund_Raiser_DetailView(ListView):
    table_class = ThemedFund_Raiser_DetailTable
    template_name = 'list_fund_raiser_detail.html'
    model = Trip_Fund_Raiser_Detail
    def get_queryset(self, **kwargs):
        return Trip_Fund_Raiser_Detail.objects.filter(fund_raiser_id=self.kwargs['frid'],
                                                      trip_commitment_id=self.kwargs['tcid'])

class ListFund_Raiser_Item_DetailView(ListView):
    table_class = Fund_Raiser_Item_DetailTable
    template_name = 'list_fund_raiser_item_detail.html'
    model = Trip_Fund_Raiser_Item_Detail
    def get_queryset(self, ** kwargs):
        return Trip_Fund_Raiser_Item_Detail.objects.filter(fund_raiser_id=self.kwargs['frid'],
                                                           trip_commitment_id=self.kwargs['tcid'])
    
class ListPaymentView(ListView):
    model = Payment
    template_name = 'list_payment.html'
    def get_queryset(self):
        return Payment.objects.filter(trip_commitment_id=self.kwargs['id'])
    
class ListTrip_CommitmentView(SingleTableView):
    table_class = ThemedTrip_CommitmentTable
    queryset = Trip_Commitment_Dashboard.objects.all().order_by('student_grade','full_name')
    # set this to false if you want to have all data on 1 page
    #table_pagination = False
    model = Trip_Commitment_Dashboard
    template_name='trip_commitment_list.html'

class UpdateStudent(UpdateView):
    form_class = StudentForm
    model = Student
    #fields='__all__'
    template_name = 'edit_student.html'
    #success_url = 'trip_commitment-list'
    def get_context_data(self, **kwargs):
        context=super(UpdateStudent, self).get_context_data(**kwargs)
        context['action'] = reverse('student-edit',
                                    kwargs={'pk': self.get_object().id})
        return context
    def get_success_url(self, *args, **kwargs):
        return reverse("trip_commitment-list")
                                                            
                                  
class UpdateTrip_CommitmentView(UpdateView):
    model = Trip_Commitment
    template_name = 'edit_trip_commitment.html'
    #fields='__all__'
    fields=('first_name','last_name','student_grade','period','going_on_trip','purchase_insurance','email','phone_1','phone_2')
    def get_success_url(self):
        return reverse('trip_commitment-list')
    def get_context_data(self, **kwargs):
        context=super(UpdateTrip_CommitmentView, self).get_context_data(**kwargs)
        context['action'] = reverse('trip_commitment-edit',
                                    kwargs={'pk': self.get_object().id})
        return context

class CreateTrip_CommitmentView(CreateView):
    model = Trip_Commitment
    template_name = 'edit_trip_commitment.html'
    fields='__all__'
    def get_success_url(self):
        return reverse('trip_commitment-list')
    def get_context_data(self, **kwargs):
        context=super(CreateTrip_CommitmentView, self).get_context_data(**kwargs)
        context['action'] = reverse('trip_commitment-new')
        return context

def student_new(request):
    if request.method == "POST":
        form = Trip_CommitmentForm(request.POST)
        if form.is_valid():
            student = form.save(commit=False)
            #Put hidden fields here list create date, create user, etc
            #student.create_date=timezone.now()
            student.save()
            return(redirect('student_detail', pk=student.pk))
    else:
        form = Trip_CommitmentForm()
    return render(request, 'trip/student_edit.html', {'form':form})

class IndexView(generic.ListView):
    template_name = 'trip/index.html'
    context_object_name = 'trip_commitment_list'

    def get_queryset(self):
        """
        Return the current trip.
        """
        return Trip_Commitment.objects.filter().order_by('student_grade','last_name','first_name')



class DetailView(generic.DetailView):
    model = Trip_Commitment
    template_name = 'trip/detail.html'
    def get_queryset(self):
        """
        Excludes any questions that aren't published yet.
        """
        return Trip_Commitment.objects.filter(current_trip=true)


class ResultsView(generic.DetailView):
    model = Trip_Commitment
    template_name = 'trip/results.html'

