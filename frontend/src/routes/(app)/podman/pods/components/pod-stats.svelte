<script lang="ts">
	import { createQuery } from '@tanstack/svelte-query';

	import { ArcaneButton } from '#lib/components/arcane-button/index.js';
	import EmptyState from '#lib/components/states/empty-state.svelte';
	import * as Card from '#lib/components/ui/card/index.js';
	import Spinner from '#lib/components/ui/spinner/spinner.svelte';
	import * as Table from '#lib/components/ui/table/index.js';
	import MonoCell from '#lib/components/vulnerability/mono-cell.svelte';
	import { StatsIcon } from '#lib/icons/index.js';
	import { m } from '#lib/paraglide/messages.js';
	import { queryKeys } from '#lib/query/query-keys.js';
	import { podmanService } from '#lib/services/podman-service.js';
	import { extractApiErrorMessage } from '#lib/utils/api.js';

	interface Props {
		podName: string;
		envId: string;
		isRunning: boolean;
	}

	let { podName, envId, isRunning }: Props = $props();

	const statsQuery = createQuery(() => ({
		queryKey: queryKeys.podman.podStats(envId, podName),
		queryFn: () => podmanService.getPodStats([podName], envId),
		enabled: isRunning,
		refetchInterval: 5000,
		retry: false
	}));
</script>

<Card.Root>
	<Card.Header icon={StatsIcon}>
		<div class="flex flex-col space-y-1.5">
			<Card.Title>
				<h2>{m.containers_resource_metrics()}</h2>
			</Card.Title>
			<Card.Description>{m.podman_pod_stats_description()}</Card.Description>
		</div>
		{#if isRunning}
			<div class="ml-auto">
				<ArcaneButton action="refresh" size="sm" disabled={statsQuery.isFetching} onclick={() => statsQuery.refetch()} />
			</div>
		{/if}
	</Card.Header>
	{#if !isRunning}
		<EmptyState icon={StatsIcon} title={m.common_unavailable()} description={m.podman_pod_not_running()} />
	{:else if statsQuery.isError}
		<EmptyState
			icon={StatsIcon}
			title={m.common_load_failed({ resource: m.containers_resource_metrics() })}
			description={extractApiErrorMessage(statsQuery.error)}
			actionLabel={m.common_retry()}
			onAction={() => statsQuery.refetch()}
		/>
	{:else if statsQuery.isPending}
		<div class="flex items-center justify-center gap-2 py-12 text-sm text-muted-foreground" role="status" aria-live="polite">
			<Spinner tone="muted" />
			<span>{m.common_loading()}</span>
		</div>
	{:else}
		<div class="overflow-x-auto rounded-b-lg">
			<Table.Root aria-label={m.containers_resource_metrics()}>
				<Table.Header>
					<Table.Row>
						<Table.Head scope="col">{m.common_name()}</Table.Head>
						<Table.Head scope="col">{m.cpu_usage()}</Table.Head>
						<Table.Head scope="col">{m.memory_usage()}</Table.Head>
						<Table.Head scope="col">{m.containers_block_io()}</Table.Head>
						<Table.Head scope="col">{m.containers_network_io()}</Table.Head>
						<Table.Head scope="col">{m.podman_pids()}</Table.Head>
					</Table.Row>
				</Table.Header>
				<Table.Body>
					{#each statsQuery.data ?? [] as stat (stat.cid)}
						<Table.Row>
							<Table.Cell>{stat.name}</Table.Cell>
							<Table.Cell><MonoCell value={stat.cpu} /></Table.Cell>
							<Table.Cell><MonoCell value={stat.memUsage} /></Table.Cell>
							<Table.Cell><MonoCell value={stat.blockIo} /></Table.Cell>
							<Table.Cell><MonoCell value={stat.netIo} /></Table.Cell>
							<Table.Cell><MonoCell value={stat.pids} /></Table.Cell>
						</Table.Row>
					{/each}
				</Table.Body>
			</Table.Root>
		</div>
	{/if}
</Card.Root>
