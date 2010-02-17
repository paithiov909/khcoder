package gui_window::doc_cls;
use base qw(gui_window);

use strict;

use Tk;

use gui_widget::tani;
use gui_widget::hinshi;
use mysql_crossout;

#-------------#
#   GUI����   #

sub _new{
	my $self = shift;
	my $mw = $::main_gui->mw;
	my $win = $self->{win_obj};
	$win->title($self->gui_jt($self->label));

	my $lf_w = $win->LabFrame(
		-label => 'Words',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'both', -expand => 1);

	$self->{words_obj} = gui_widget::words->open(
		parent => $lf_w,
		verb   => '����',
	);

	my $lf = $win->LabFrame(
		-label => 'Options',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'x', -expand => 0);

	# ���饹������
	my $f4 = $lf->Frame()->pack(
		-fill => 'x',
		-pady => 2
	);

	$f4->Label(
		-text => $self->gui_jchar('����Υ��'),
		-font => "TKFN",
	)->pack(-side => 'left');

	my $widget_dist = gui_widget::optmenu->open(
		parent  => $f4,
		pack    => {-side => 'left'},
		options =>
			[
				['Jaccard', 'binary'],
				['Euclid',  'euclid'],
			],
		variable => \$self->{method_dist},
	);
	$widget_dist->set_value('binary');


	$f4->Label(
		-text => $self->gui_jchar('  ���饹��������'),
		-font => "TKFN",
	)->pack(-side => 'left');

	$self->{entry_cluster_number} = $f4->Entry(
		-font       => "TKFN",
		-width      => 4,
		-background => 'white',
	)->pack(-side => 'left', -padx => 2);
	$self->{entry_cluster_number}->insert(0,'10');
	$self->{entry_cluster_number}->bind("<Key-Return>",sub{$self->calc;});
	$self->config_entry_focusin($self->{entry_cluster_number});

	$win->Button(
		-text => $self->gui_jchar('����󥻥�'),
		-font => "TKFN",
		-width => 8,
		-command => sub{ $mw->after(10,sub{$self->close;});}
	)->pack(-side => 'right',-padx => 2, -pady => 2, -anchor => 'se');

	$win->Button(
		-text => 'OK',
		-width => 8,
		-font => "TKFN",
		-command => sub{ $mw->after(10,sub{$self->calc;});}
	)->pack(-side => 'right', -pady => 2, -anchor => 'se');


	return $self;
}

#--------------#
#   �����å�   #
sub check{
	my $self = shift;
	
	unless ( eval(@{$self->hinshi}) ){
		gui_errormsg->open(
			type => 'msg',
			msg  => '�ʻ줬1�Ĥ����򤵤�Ƥ��ޤ���',
		);
		return 0;
	}
	
	my $tani2 = '';
	if ($self->{radio} == 0){
		$tani2 = $self->gui_jg($self->{high});
	}
	elsif ($self->{radio} == 1){
		if ( length($self->{var_id}) ){
			$tani2 = mysql_outvar::a_var->new(undef,$self->{var_id})->{tani};
		}
	}
	
	my $check = mysql_crossout::r_com->new(
		tani   => $self->tani,
		tani2  => $tani2,
		hinshi => $self->hinshi,
		max    => $self->max,
		min    => $self->min,
		max_df => $self->max_df,
		min_df => $self->min_df,
	)->wnum;
	
	$self->{ent_check}->configure(-state => 'normal');
	$self->{ent_check}->delete(0,'end');
	$self->{ent_check}->insert(0,$check);
	$self->{ent_check}->configure(-state => 'disable');
}

#----------#
#   �¹�   #

sub calc{
	my $self = shift;
	
	# ���ϤΥ����å�
	unless ( eval(@{$self->hinshi}) ){
		gui_errormsg->open(
			type => 'msg',
			msg  => '�ʻ줬1�Ĥ����򤵤�Ƥ��ޤ���',
		);
		return 0;
	}

	my $check_num = mysql_crossout::r_com->new(
		tani     => $self->tani,
		tani2    => $self->tani,
		hinshi   => $self->hinshi,
		max      => $self->max,
		min      => $self->min,
		max_df   => $self->max_df,
		min_df   => $self->min_df,
	)->wnum;
	
	$check_num =~ s/,//g;
	#print "$check_num\n";

	if ($check_num < 3){
		gui_errormsg->open(
			type => 'msg',
			msg  => '���ʤ��Ȥ�3�İʾ����и�����򤷤Ʋ�������',
		);
		return 0;
	}

	#if ($check_num > 500){
	#	my $ans = $self->win_obj->messageBox(
	#		-message => $self->gui_jchar
	#			(
	#				 '���ߤ�����Ǥ�'.$check_num.'�줬���Ѥ���ޤ���'
	#				."\n"
	#				.'���Ѥ����ο���200��300���٤ˤ������뤳�Ȥ�侩���ޤ���'
	#				."\n"
	#				.'³�Ԥ��Ƥ�������Ǥ�����'
	#			),
	#		-icon    => 'question',
	#		-type    => 'OKCancel',
	#		-title   => 'KH Coder'
	#	);
	#	unless ($ans =~ /ok/i){ return 0; }
	#}

	my $ans = $self->win_obj->messageBox(
		-message => $self->gui_jchar
			(
			   "���ν����ˤϻ��֤������뤳�Ȥ�����ޤ���\n".
			   "³�Ԥ��Ƥ�������Ǥ�����"
			),
		-icon    => 'question',
		-type    => 'OKCancel',
		-title   => 'KH Coder'
	);
	unless ($ans =~ /ok/i){ return 0; }

	#my $w = gui_wait->start;

	# �ǡ����μ��Ф�
	my $r_command = mysql_crossout::r_com->new(
		tani   => $self->tani,
		tani2  => $self->tani,
		hinshi => $self->hinshi,
		max    => $self->max,
		min    => $self->min,
		max_df => $self->max_df,
		min_df => $self->min_df,
		rownames => 0,
	)->run;

	# ���饹����ʬ�Ϥ�¹Ԥ��뤿��Υ��ޥ��
	$r_command .= "# END: DATA\n";

	&calc_exec(
		base_win       => $self,
		cluster_number => $self->gui_jg( $self->{entry_cluster_number}->get ),
		r_command      => $r_command,
		method_dist    => $self->{method_dist},
		tani           => $self->tani,
	);
}

sub calc_exec{
	my %args = @_;

	my $r_command = $args{r_command};
	my $cluster_number = $args{cluster_number};

	my $file = $::project_obj->file_datadir.'_doc_cls_ward';
	
	my $icode;
	if ($::config_obj->os eq 'win32'){
		$file = Jcode->new($file,'sjis')->euc;
		$file =~ s/\\/\\\\/g;
		#$file = Jcode->new($file,'euc')->sjis;
	} else {
		$icode = Jcode::getcode($file);
		$file = Jcode->new($file, $icode)->euc unless $icode eq 'euc';
		$file =~ s/\\/\\\\/g;
		#$file = Jcode->new($file,'euc')->$icode unless $icode eq 'ascii';
	}

	# R�ˤ��׻�
	if ($args{method_dist} eq 'euclid'){
		$r_command .= "d <- scale( d )\n";
		$r_command .= "dj <- dist(d,method=\"euclid\")^2\n";
	} else {
		$r_command .= "dj <- dist(d,method=\"binary\")\n";
	}

	$r_command .= "dcls <- hclust(dj, method=\"ward\")\n";
	$r_command .= "r    <- cutree(dcls,k=$cluster_number)\n";

	$r_command .= "dcls <- hclust(dj, method=\"average\")\n";
	$r_command .= "r    <- cbind(r, cutree(dcls,k=$cluster_number))\n";

	$r_command .= "dcls <- hclust(dj, method=\"complete\")\n";
	$r_command .= "r    <- cbind(r, cutree(dcls,k=$cluster_number))\n";


	$r_command .= "colnames(r) <- 
		c(\"_cluster_tmp_w\",\"_cluster_tmp_a\",\"_cluster_tmp_c\")\n";
	$r_command .= "write.table(r, file=\"$file\", row.names=F, append=F, sep=\"\\t\", quote=F)\n";
	$r_command .= "print(\"ok\")\n";

	$r_command = Jcode->new($r_command,'euc')->sjis
		if $::config_obj->os eq 'win32';

	$::config_obj->R->send($r_command);
	my $r = $::config_obj->R->read;

	if (
		   ( $r =~ /error/i )
		or ( index($r, '���顼') > -1 )
		or ( index($r, Jcode->new('���顼','euc')->sjis) > -1 )
	) {
		gui_errormsg->open(
			type   => 'msg',
			window  => \$::main_gui->mw,
			msg    => "�׻��˼��Ԥ��ޤ���\n\n".$r
		);
		return 0;
	}

	$args{base_win}->close;
	if ($::main_gui->if_opened('w_doc_cls_res')){
		$::main_gui->get('w_doc_cls_res')->close;
	}

	# R�η׻���̤����ѿ��Ȥ����ɤ߹���
	foreach my $i (@{mysql_outvar->get_list}){
		if ($i->[1] =~ /^_cluster_tmp_[wac]$/){
			mysql_outvar->delete(name => $i->[1]);
		}
	}

	$file =~ s/\\\\/\\/g;
	if ($::config_obj->os eq 'win32'){
		$file = Jcode->new($file,'euc')->sjis;
	} else {
		$file = Jcode->new($file,'euc')->$icode unless $icode eq 'ascii';
	}

	mysql_outvar::read::tab->new(
		file     => $file,
		tani     => $args{tani},
		var_type => 'INT',
	)->read;

	gui_window::doc_cls_res->open(
		command_f => $r_command,
		tani      => $args{tani},
	);

	return 1;
}

#--------------#
#   ��������   #


sub label{
	return 'ʸ�񡦥��饹����ʬ�ϡ����ץ����';
}

sub win_name{
	return 'w_doc_cls';
}

sub min{
	my $self = shift;
	return $self->{words_obj}->min;
}
sub max{
	my $self = shift;
	return $self->{words_obj}->max;
}
sub min_df{
	my $self = shift;
	return $self->{words_obj}->min_df;
}
sub max_df{
	my $self = shift;
	return $self->{words_obj}->max_df;
}
sub tani{
	my $self = shift;
	return $self->{words_obj}->tani;
}
sub hinshi{
	my $self = shift;
	return $self->{words_obj}->hinshi;
}




1;