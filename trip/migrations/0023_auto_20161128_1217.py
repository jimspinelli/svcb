# -*- coding: utf-8 -*-
# Generated by Django 1.10.3 on 2016-11-28 17:17
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('trip', '0022_student_svid'),
    ]

    operations = [
        migrations.RenameField(
            model_name='student',
            old_name='email',
            new_name='email_1',
        ),
        migrations.AddField(
            model_name='student',
            name='email_2',
            field=models.CharField(blank=True, max_length=75, null=True),
        ),
    ]
