// https://github.com/timc1/kbar/blob/main/example/src/App.tsx

import React from 'react';
import {
	KBarProvider,
	KBarPortal,
	KBarPositioner,
	KBarAnimator,
	KBarSearch,
	useMatches,
	KBarResults,
} from 'kbar';

const searchStyle = {
	padding: '12px 16px',
	fontSize: '16px',
	width: '100%',
	boxSizing: 'border-box',
	outline: 'none',
	border: 'none',
	background: 'rgb(28 28 29)',
	color: 'rgba(252 252 252 / 0.9)',
};

const animatorStyle = {
	maxWidth: '600px',
	width: '100%',
	background: 'rgb(28 28 29)',
	color: 'rgba(252 252 252 / 0.9)',
	borderRadius: '8px',
	overflow: 'hidden',
	boxShadow: 'rgb(0 0 0 / 50%) 0px 16px 70px',
};

const groupNameStyle = {
	padding: '8px 16px',
	fontSize: '10px',
	textTransform: 'uppercase',
	opacity: 0.5,
};

export default function Context(props) {
	const actions = [
		{
			id: 'event_hq',
			name: 'HQ',
			shortcut: ['h', 'q'],
			keywords: 'Hack Club HQ',
			perform: () => (window.location.pathname = 'hq'),
		},
		{
			id: 'user_settings',
			name: 'User Settings',
			shortcut: ['s'],
			keywords: 'User Settings',
			perform: () => (window.location.pathname = 'my/settings'),
		},
		{
			id: 'dark_mode',
			name: 'Dark Mode',
			shortcut: ['d'],
			keywords: 'dark mode',
			perform: () => BK.styleDark(true),
		},
		{
			id: 'light_mode',
			name: 'Light Mode',
			shortcut: ['l'],
			keywords: 'light mode',
			perform: () => BK.styleDark(false),
		},
	];

	console.log(props);

	return (
		<>
			<KBarProvider actions={actions}>
				<CommandBar />
				<div dangerouslySetInnerHTML={{ __html: props.Html }}>
					{/*
						react-rails doesn't support childrens... PLEASE WHY?!
						https://github.com/reactjs/react-rails/issues/223
					*/}
				</div>
			</KBarProvider>
		</>
	);
}

function CommandBar() {
	return (
		<KBarPortal>
			<KBarPositioner style={{ zIndex: 99 }}>
				<KBarAnimator style={animatorStyle}>
					<KBarSearch style={searchStyle} />
					<RenderResults />
				</KBarAnimator>
			</KBarPositioner>
		</KBarPortal>
	);
}

function RenderResults() {
	const { results, rootActionId } = useMatches();

	return (
		<KBarResults
			items={results}
			onRender={({ item, active }) =>
				typeof item === 'string' ? (
					<div style={groupNameStyle}>{item}</div>
				) : (
					<ResultItem
						action={item}
						active={active}
						currentRootActionId={rootActionId}
					/>
				)
			}
		/>
	);
}

const ResultItem = React.forwardRef(
	({ action, active, currentRootActionId }, ref) => {
		const ancestors = React.useMemo(() => {
			if (!currentRootActionId) return action.ancestors;
			const index = action.ancestors.findIndex(
				(ancestor) => ancestor.id === currentRootActionId
			);
			// +1 removes the currentRootAction; e.g.
			// if we are on the "Set theme" parent action,
			// the UI should not display "Set theme… > Dark"
			// but rather just "Dark"
			return action.ancestors.slice(index + 1);
		}, [action.ancestors, currentRootActionId]);

		return (
			<div
				ref={ref}
				style={{
					padding: '12px 16px',
					background: active ? 'rgb(53 53 54)' : 'transparent',
					borderLeft: `2px solid ${
						active ? 'rgba(252 252 252 / 0.9)' : 'transparent'
					}`,
					display: 'flex',
					alignItems: 'center',
					justifyContent: 'space-between',
					cursor: 'pointer',
				}}
			>
				<div
					style={{
						display: 'flex',
						gap: '8px',
						alignItems: 'center',
						fontSize: 14,
					}}
				>
					{action.icon && action.icon}
					<div style={{ display: 'flex', flexDirection: 'column' }}>
						<div>
							{ancestors.length > 0 &&
								ancestors.map((ancestor) => (
									<React.Fragment key={ancestor.id}>
										<span
											style={{
												opacity: 0.5,
												marginRight: 8,
											}}
										>
											{ancestor.name}
										</span>
										<span
											style={{
												marginRight: 8,
											}}
										>
											&rsaquo;
										</span>
									</React.Fragment>
								))}
							<span>{action.name}</span>
						</div>
						{action.subtitle && (
							<span style={{ fontSize: 12 }}>{action.subtitle}</span>
						)}
					</div>
				</div>
				{action.shortcut?.length ? (
					<div
						aria-hidden
						style={{ display: 'grid', gridAutoFlow: 'column', gap: '4px' }}
					>
						{action.shortcut.map((sc) => (
							<kbd
								key={sc}
								style={{
									padding: '4px 6px',
									background: 'rgba(0 0 0 / .1)',
									borderRadius: '4px',
									fontSize: 14,
								}}
							>
								{sc}
							</kbd>
						))}
					</div>
				) : null}
			</div>
		);
	}
);
