import { visualize, DagNode, DagView, Row, Thread } from "./dag-view";
import React, { useMemo } from "react";

export interface ViewDagNode extends DagNode {
    message?: string
}

const CELL_SIZE = 20;
const NODE_RADIUS = 5;

export function DagViewComponent({ nodes, frontiers }: { nodes: ViewDagNode[], frontiers: string[] }) {
    const view = useMemo(() => {
        const map = new Map<string, DagNode>();
        for (const node of nodes) {
            map.set(node.id, node);
        }
        return visualize(id => map.get(id), frontiers);
    }, [nodes, frontiers]);

    const svgContent = renderDagAsSvg(view);

    return (
        <svg width={svgContent.width} height={svgContent.height}>
            {svgContent.elements}
        </svg>
    );
}

function renderDagAsSvg(view: DagView) {
    const elements: JSX.Element[] = [];
    let maxWidth = 0;

    view.rows.forEach((row: Row, rowIndex: number) => {
        const rowElements = renderRowAsSvg(row, rowIndex);
        elements.push(...rowElements);
        maxWidth = Math.max(maxWidth, (Math.max(row.cur_tids.length, row.output.length, row.input.length) + 3) * CELL_SIZE);
    });

    return {
        width: maxWidth,
        height: view.rows.length * CELL_SIZE * 2,
        elements
    };
}

function renderRowAsSvg(row: Row, rowIndex: number): JSX.Element[] {
    const elements: JSX.Element[] = [];
    const y = rowIndex * CELL_SIZE * 2;

    // Render connections
    const inputConn = renderConnections(row, 'input', y - CELL_SIZE / 2);
    const outputConn = renderConnections(row, 'output', y + CELL_SIZE / 2);
    elements.push(...inputConn, ...outputConn);

    // Render nodes
    row.cur_tids.forEach((tid: number, index: number) => {
        const x = index * CELL_SIZE + CELL_SIZE / 2;
        const isActive = tid === row.active.tid;
        elements.push(
            <circle
                key={`node-${rowIndex}-${index}`}
                cx={x}
                cy={y + CELL_SIZE / 2}
                r={NODE_RADIUS}
                fill={isActive ? "red" : "black"}
            />
        );
    });

    // Render node ID
    elements.push(
        <text
            key={`text-${rowIndex}`}
            x={Math.max(row.input.length, row.cur_tids.length) * CELL_SIZE + 5}
            y={y + CELL_SIZE / 2 + 5}
            fontSize="12"
            fontFamily="'Helvetica Neue', Arial, sans-serif"
        >
            {(row.active.node as ViewDagNode).message ?? row.active.node.id}
        </text>
    );

    return elements;
}

function renderConnections(row: Row, type: 'input' | 'output', y: number): JSX.Element[] {
    const ans: JSX.Element[] = []
    row[type].forEach((thread: Thread, i: number) => {
        const connectionA = row.cur_tids.indexOf(thread.tid);
        const connectionB = thread.dep_on_active ? row.active_index : -1;
        if (connectionA >= 0) {
            ans.push(renderConnection(type, i, connectionA, y, thread.tid))
        }
        if (connectionB >= 0) {
            ans.push(renderConnection(type, i, connectionB, y, thread.tid))
        }
    });

    return ans;
}

function renderConnection(type: 'input' | 'output', xFrom: number, xTo: number, y: number, tid: number): JSX.Element {
    const startX = xFrom * CELL_SIZE + CELL_SIZE / 2;
    const endX = xTo * CELL_SIZE + CELL_SIZE / 2;
    const startY = type === 'input' ? y : y + CELL_SIZE;
    const endY = type === 'input' ? y + CELL_SIZE : y;

    let path = ""
    if (startX > endX) {
        const controlPoint1X = startX;
        const controlPoint1Y = startY + (endY - startY) / 2
        const controlPoint2X = startX + (endX - startX) / 2
        const controlPoint2Y = endY
        path = `M ${startX} ${startY} C ${controlPoint1X} ${controlPoint1Y}, ${controlPoint2X} ${controlPoint2Y}, ${endX} ${endY}`;
    } else {
        const controlPoint1X = startX + (endX - startX) / 2;
        const controlPoint1Y = startY
        const controlPoint2X = endX
        const controlPoint2Y = endY
        path = `M ${startX} ${startY} C ${controlPoint1X} ${controlPoint1Y}, ${controlPoint2X} ${controlPoint2Y}, ${endX} ${endY}`;
    }

    return (
        <path
            key={`connection-${type}-${tid}-${xFrom}-${xTo}`}
            d={path}
            fill="none"
            stroke={tidToColor(tid)}
            strokeWidth="2"
        />
    );
}

function tidToColor(tid: number): string {
    // Generate a beautiful color based on the thread ID
    const hue = (tid * 137.508) % 360; // Golden angle approximation for even distribution
    const saturation = 70 + (tid % 30); // Vary saturation between 70% and 100%
    const lightness = 45 + (tid % 20); // Vary lightness between 45% and 65%

    return `hsl(${hue}, ${saturation}%, ${lightness}%)`;
}
