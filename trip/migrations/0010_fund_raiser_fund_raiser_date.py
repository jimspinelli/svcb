# -*- coding: utf-8 -*-
# Generated by Django 1.10.3 on 2016-11-11 03:40
from __future__ import unicode_literals

from django.db import migrations, models
import django.utils.timezone


class Migration(migrations.Migration):

    dependencies = [
        ('trip', '0009_auto_20161110_2229'),
    ]

    operations = [
        migrations.AddField(
            model_name='fund_raiser',
            name='fund_raiser_date',
            field=models.DateField(default=django.utils.timezone.now),
            preserve_default=False,
        ),
    ]