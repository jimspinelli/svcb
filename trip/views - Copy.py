#from django.shortcuts import render
#from django.http import HttpResponseRedirect
#from django.urls import reverse
from django.views import generic
#from django.utils import timezone
#from django.core.urlresolvers import reverse
#from django.utils.lorem_ipsum import words
#from django.views.generic.base import TemplateView
from django.core.urlresolvers import reverse
from django.shortcuts import render, redirect, get_object_or_404
from django.utils.lorem_ipsum import words
from django.views.generic.base import TemplateView
from django.views.generic import UpdateView
from django.http import Http404

from django_tables2 import MultiTableMixin, RequestConfig, SingleTableView

# Create your views here.
from .models import Trip_Commitment_Dashboard,Trip,Trip_current_payment_due,Trip_Commitment
from .tables import (ThemedTrip_CommitmentTable)
from .forms import Trip_CommitmentForm,ContactForm

#class ContactView(FormView):
#    template_name='contact.html'
#    form_class=ContactForm
#    success_url='/thanks/'
#    def form_valid(self, form):
#        form.send_mail()
#        return super(ContactView, self).form_valid(form)
    
# Used to populate header of Trip Commitment Dashboard
def trip(request):
    return render("class_based.html",context_instance=RequestContext(request))

# Used to populate header of Trip Commitment Dashboard
def current_payment_date(request):
    return render("class_based.html",context_instance=RequestContext(request))

class Trip_Commitment(SingleTableView):
    table_class = ThemedTrip_CommitmentTable
    queryset = Trip_Commitment_Dashboard.objects.all().order_by('student_grade','full_name')
    template_name = 'class_based.html'
    #table_pagination = False

class StudentUpdateView(UpdateView):
    model = Trip_Commitment
    template_name = 'edit_student.html'
    fields='__all__'
    def get_success_url(self):
        return reverse('class_based')
    def get_context_data(self, **kwargs):
        context=super(StudentUpdateView, self).get_context_data(**kwargs)
        context['action'] = reverse('edit_student',
                                    kwargs={'pk': self.get_object().id})
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

#def vote(request, question_id):
#    question = get_object_or_404(Question, pk=question_id)
#    try:
#        selected_choice = question.choice_set.get(pk=request.POST['choice'])
#    except (KeyError, Choice.DoesNotExist):
        # Redisplay the question voting form.
#        return render(request, 'polls/detail.html', {
#            'question': question,
#            'error_message': "You didn't select a choice.",
#        })
#    else:
#        selected_choice.votes += 1
#        selected_choice.save()
        # Always return an HttpResponseRedirect after successfully dealing
        # with POST data. This prevents data from being posted twice if a
        # user hits the Back button.
#        return HttpResponseRedirect(reverse('polls:results', args=(question.id,)))

