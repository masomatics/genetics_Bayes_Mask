
time = 1:T_counter;
figure(1);
set(gca,'FontName','Helvetica','FontSize',20);
plot(time,Bt_total(1,time),'r','LineWidth',2);
hold on
for k = 2:K
    plot(time,Bt_total(k,time),'b','LineWidth',2);
end
hold off
xlabel('Iteration number');
ylabel('Theta value');
xlim([-1,T_counter+1]);
saveas(figure(1),'Beta.eps','epsc2');

figure(2);
set(gca,'FontName','Helvetica','FontSize',20);
plot(time,Pt_total(1,time),'r','LineWidth',2);
hold on
for k = 2:K
    plot(time,Pt_total(k,time),'b','LineWidth',2);
end
hold off
xlabel('Iteration number');
ylabel('Pi value');
xlim([-1,T_counter+1]);
ylim([-0.1,1.1]);
saveas(figure(2),'Pi.eps','epsc2');

figure(3);
set(gca,'FontName','Helvetica','FontSize',20);
plot(time,Lt_total(time),'r','LineWidth',2);
xlabel('Iteration number');
ylabel('lambda value');
xlim([-1,T_counter+1]);
%ylim([-0.1,1.1]);
saveas(figure(3),'lambda.eps','epsc2');

%
figure(4);
set(gca,'FontName','Helvetica','FontSize',20);
plot(calc_time,rec_n_pruned_correct,'r','LineWidth',2);
hold on
plot(calc_time,rec_n_pruned_total - rec_n_pruned_correct,'b','LineWidth',2);
hold off
xlabel('Elapsed time (sec)');
ylabel('Recall');
xlim([-1,calc_time(I_max)+1]);
%ylim([-0.1,1.1]);
figname = sprintf('%s/calctime_SEED%d_TEMEG%d_N%d.eps',dname,SEED,T_EM_EG,N);
saveas(figure(4),figname,'epsc2');