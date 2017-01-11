from trip.models import Trip, Trip_current_payment_due, Trip_Commitment_Dashboard
from trip.tables import ThemedTrip_CommitmentTable,PaymentTable

# REMEMBER TO REGISTER THESE IN SETTINGS.PY CONTEXT_PROCESSORS!!!
def trip(context):
  return {'trip': Trip.objects.filter(current_trip=True)}

def current_payment_date(context):
  return {'current_payment_date': Trip_current_payment_due.objects.filter(current_trip=True)}

def student_name(context):
  #return {'student_name': Trip_Commitment.objects}
  if hasattr(context, 'resolver_match'):
      sid = context.resolver_match.kwargs.get('tcid')
      if sid:
          return {'student_name': Trip_Commitment_Dashboard.objects.get(trip_commitment_id=sid).full_name}
      else:
          sid = context.resolver_match.kwargs.get('id')
          if sid:
            return {'student_name': Trip_Commitment_Dashboard.objects.get(trip_commitment_id=sid).full_name}
          else:
            sid = context.resolver_match.kwargs.get('pk')
            if sid:
              s = Trip_Commitment_Dashboard.objects.get(id=sid).full_name
              return {'student_name': Trip_Commitment_Dashboard.objects.get(id=sid).full_name}
  return {}

#def payments(context):
#  return {'payments': Payments.objects.filter(id=4)}
  #return {'payments': ThemedTrip_CommitmentTable.objects.filter(id=24)}

