part of 'admin_pages.dart';

enum _ReportPeriod { today, sevenDays, thirtyDays, custom }

class AdminReportsPage extends ConsumerStatefulWidget {
  const AdminReportsPage({super.key});

  @override
  ConsumerState<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends ConsumerState<AdminReportsPage> {
  _ReportPeriod period = _ReportPeriod.thirtyDays;
  DateTimeRange? customRange;

  @override
  Widget build(BuildContext context) {
    final t = adminText(context);
    final reporting = ref.watch(adminReportingProvider);
    return AdminPageFrame(
      title: t.reportsAndSync,
      action: OutlinedButton.icon(
        onPressed: () => _chooseExport(context),
        icon: const Icon(Icons.download_outlined),
        label: Text(t.exportCsv),
      ),
      child: reporting.when(
        loading: () => const BmAdminSkeleton(),
        error: (_, __) => BmEmptyState(
          title: t.unableSync,
          actionLabel: t.tryAgain,
          onAction: () => ref.invalidate(adminReportingProvider),
        ),
        data: (data) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final range = switch (period) {
            _ReportPeriod.today => DateTimeRange(start: today, end: today),
            _ReportPeriod.sevenDays => DateTimeRange(
                start: today.subtract(const Duration(days: 6)), end: today),
            _ReportPeriod.thirtyDays => DateTimeRange(
                start: today.subtract(const Duration(days: 29)), end: today),
            _ReportPeriod.custom =>
              customRange ?? DateTimeRange(start: today, end: today),
          };
          final view = data.forRange(range.start, range.end);
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            children: <Widget>[
              DropdownButtonFormField<_ReportPeriod>(
                initialValue: period,
                decoration: InputDecoration(labelText: t.dateRange),
                items: <DropdownMenuItem<_ReportPeriod>>[
                  DropdownMenuItem(
                    value: _ReportPeriod.today,
                    child: Text(t.today),
                  ),
                  DropdownMenuItem(
                    value: _ReportPeriod.sevenDays,
                    child: Text(t.sevenDays),
                  ),
                  DropdownMenuItem(
                    value: _ReportPeriod.thirtyDays,
                    child: Text(t.thirtyDays),
                  ),
                  DropdownMenuItem(
                    value: _ReportPeriod.custom,
                    child: Text(t.customRange),
                  ),
                ],
                onChanged: (value) => _changePeriod(value, today),
              ),
              const SizedBox(height: 18),
              Wrap(spacing: 12, runSpacing: 12, children: <Widget>[
                AdminMetric(t.totalOrders, '${view.totalOrders}',
                    Icons.receipt_long_outlined),
                AdminMetric(t.recognizedRevenue,
                    '₹${_money(view.recognizedRevenue)}', Icons.show_chart),
                AdminMetric(
                    t.synced, '${data.synced}', Icons.cloud_done_outlined),
                AdminMetric(
                    t.syncNeedsAttention,
                    '${data.pending + data.failed}',
                    Icons.sync_problem_rounded),
              ]),
              const SizedBox(height: 24),
              Text(t.reportingSync,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(t.reportingSourceTruth),
              const SizedBox(height: 10),
              for (final job in data.recentJobs) _SyncJobTile(job: job),
              const SizedBox(height: 24),
              Wrap(spacing: 12, runSpacing: 12, children: <Widget>[
                AdminMetric(t.completed, '${view.completedOrders}',
                    Icons.check_circle_outline_rounded),
                AdminMetric(t.cancelledOrders, '${view.cancelledOrders}',
                    Icons.cancel_outlined),
                AdminMetric(t.pending, '${view.pendingOrders}',
                    Icons.hourglass_empty_rounded),
                AdminMetric(t.paidTotal, '₹${_money(view.paidTotal)}',
                    Icons.payments_outlined),
                AdminMetric(t.unpaidTotal, '₹${_money(view.unpaidTotal)}',
                    Icons.money_off_outlined),
                AdminMetric(t.todayRevenue, '₹${_money(view.todayRevenue)}',
                    Icons.today_outlined),
                AdminMetric(t.monthlyRevenue, '₹${_money(view.monthlyRevenue)}',
                    Icons.calendar_month_outlined),
              ]),
              const SizedBox(height: 24),
              Text(t.revenueChart,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Card(
                child: SizedBox(
                  height: 220,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: CustomPaint(
                      painter: _RevenueChart(view.revenueByDay),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(t.topMaterials,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (view.topMaterials.isEmpty)
                Text(t.noReportData)
              else
                for (var i = 0; i < view.topMaterials.length; i++)
                  ListTile(
                    leading: CircleAvatar(child: Text('${i + 1}')),
                    title: Text(view.topMaterials[i].name),
                    subtitle: Text(
                      '${t.orderCount}: ${view.topMaterials[i].orderCount} · ${t.revenue}: ₹${_money(view.topMaterials[i].revenue)}',
                    ),
                    trailing: Text(
                      '${t.quantity}: ${view.topMaterials[i].quantity}',
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _changePeriod(_ReportPeriod? value, DateTime today) async {
    if (value == null) return;
    if (value == _ReportPeriod.custom) {
      final selected = await showDateRangePicker(
        context: context,
        firstDate: DateTime(today.year - 3),
        lastDate: today,
        initialDateRange: customRange,
      );
      if (selected == null || !mounted) return;
      setState(() {
        customRange = selected;
        period = value;
      });
      return;
    }
    setState(() => period = value);
  }

  Future<void> _chooseExport(BuildContext context) async {
    final t = adminText(context);
    final reportType = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: Text(t.ordersReport),
            onTap: () => Navigator.pop(sheetContext, 'orders'),
          ),
          ListTile(
            leading: const Icon(Icons.show_chart_rounded),
            title: Text(t.revenueReport),
            onTap: () => Navigator.pop(sheetContext, 'revenue'),
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: Text(t.productsReport),
            onTap: () => Navigator.pop(sheetContext, 'products'),
          ),
          ListTile(
            leading: const Icon(Icons.people_outline_rounded),
            title: Text(t.customersReport),
            onTap: () => Navigator.pop(sheetContext, 'customers'),
          ),
        ]),
      ),
    );
    if (reportType != null && context.mounted) {
      await _export(context, reportType);
    }
  }

  Future<void> _export(BuildContext context, String reportType) async {
    final t = adminText(context);
    try {
      final csv =
          await ref.read(adminRepositoryProvider).exportReportCsv(reportType);
      await Clipboard.setData(ClipboardData(text: '\uFEFF$csv'));
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(t.csvCopied)));
      }
    } on AdminFailure {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(t.csvError)));
      }
    }
  }
}

class _SyncJobTile extends ConsumerWidget {
  const _SyncJobTile({required this.job});
  final ReportSyncJob job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = adminText(context);
    return Card(
      child: ListTile(
        leading: Icon(job.needsAttention
            ? Icons.error_outline_rounded
            : Icons.sync_rounded),
        title: Text(job.orderNumber ?? job.orderId),
        subtitle: Text(
          '${job.status.name} · ${t.lastSync}: ${_dateTime(job.updatedAt)} · ${t.attempts}: ${job.attemptCount}'
          '${job.lastError == null ? '' : ' · ${job.lastError}'}',
        ),
        trailing: job.needsAttention
            ? TextButton(
                onPressed: () async {
                  await ref
                      .read(adminRepositoryProvider)
                      .retryReportSync(job.orderId);
                  ref.invalidate(adminReportingProvider);
                },
                child: Text(t.retrySync),
              )
            : null,
      ),
    );
  }
}

class _RevenueChart extends CustomPainter {
  _RevenueChart(this.points);
  final List<AdminRevenuePoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    final axis = Paint()
      ..color = BmColors.border
      ..strokeWidth = 1;
    canvas.drawLine(
        Offset(0, size.height), Offset(size.width, size.height), axis);
    if (points.isEmpty) return;
    final maxAmount = points
        .map((point) => point.amount.toDouble())
        .fold<double>(0, (max, value) => value > max ? value : max);
    final path = Path();
    for (var index = 0; index < points.length; index++) {
      final x = points.length == 1
          ? size.width / 2
          : size.width * index / (points.length - 1);
      final y = maxAmount <= 0
          ? size.height
          : size.height - (points[index].amount / maxAmount * size.height * .9);
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()..color = BmColors.orange,
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = BmColors.orange
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RevenueChart oldDelegate) => oldDelegate.points != points;
}
