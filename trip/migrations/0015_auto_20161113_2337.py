# -*- coding: utf-8 -*-
# Generated by Django 1.9.11 on 2016-11-14 04:37
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('trip', '0014_auto_20161113_2255'),
    ]

    operations = [
        migrations.AlterField(
            model_name='trip_payment_date',
            name='payment_amount',
            field=models.DecimalField(blank=True, decimal_places=2, max_digits=6, null=True, verbose_name='payment_Amount'),
        ),
    ]
