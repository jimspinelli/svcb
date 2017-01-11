from django import forms
from django.forms.models import inlineformset_factory

from .models import Payment,Student,Trip_Commitment

class StudentForm(forms.ModelForm):
    class Meta:
        model=Student
        fields=('first_name',
                'last_name',
                'svid',
                'email_1',
                'email_2',
                'phone_1',
                'phone_2')
    #def __init__(self, *args, **kwargs):
    #    super(StudentForm,self).__init__(args, **kwargs)
    #def save(self, id):
    #    print(id)
    #    instance = super(StudentForm, self).save(commit=False)
    #    instance.save()
    #    return instance

class TripCommitmentForm(forms.ModelForm):
    class Meta:
        model=Trip_Commitment
        fields=('student_grade',
                'period',
                'trip',
                'going_on_trip',
                'purchase_insurance')

TripCommitmentFormSet = inlineformset_factory(Student,Trip_Commitment,extra=0, min_num=1,
                                              can_delete=False,
                                              fields=('student_grade',
                                                      'period',
                                                      'trip',
                                                      'going_on_trip',
                                                      'purchase_insurance'))

class CreatePaymentForm(forms.ModelForm):
    def __init__(self, *args, **kwargs):
        #self.student_name=Trip_Commitment_Dashboard.objects.all().filter(trip_commitment_id=kwargs['id'])
        super(CreatePaymentForm, self).__init__(*args, **kwargs)
    class Meta:
        model=Payment
        fields=["payment_amount","check_number","payment_date","deposit_date",]
        
class PaymentForm(forms.ModelForm):
    class Meta:
        model=Payment
        fields=["payment_amount","check_number","payment_date","deposit_date",]
    
#class Trip_CommitmentForm(forms.ModelForm):
#    class Meta:
#        model=Trip_Commitment
#        fields=('first_name',
#                'last_name',
#                'student_grade',
#                'period',
#                'going_on_trip',
#                'purchase_insurance',
#                'email',
#                'phone_1',
#                'phone_2',
#                'trip')
